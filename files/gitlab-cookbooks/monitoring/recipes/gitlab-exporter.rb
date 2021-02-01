#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# Copyright:: Copyright (c) 2016 GitLab Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
account_helper = AccountHelper.new(node)
redis_helper = RedisHelper.new(node)
gitlab_user = account_helper.gitlab_user
gitlab_exporter_dir = node['monitoring']['gitlab-exporter']['home']
gitlab_exporter_log_dir = node['monitoring']['gitlab-exporter']['log_directory']

directory gitlab_exporter_dir do
  owner gitlab_user
  mode "0755"
  recursive true
end

# This runit service was made obsolete in 12.3
runit_service "gitlab-monitor" do
  action :disable
end

# This legacy directory was made obsolete in 12.3
if gitlab_exporter_dir != '/var/opt/gitlab/gitlab-monitor'
  directory '/var/opt/gitlab/gitlab-monitor' do
    action :delete
    recursive true
  end
end

directory gitlab_exporter_log_dir do
  owner gitlab_user
  mode "0700"
  recursive true
end

connection_string = "dbname=#{node['gitlab']['gitlab-rails']['db_database']} user=#{node['gitlab']['gitlab-rails']['db_username']}"

connection_string += if node['postgresql']['enabled']
                       " host=#{node['postgresql']['dir']}"
                     else
                       " host=#{node['gitlab']['gitlab-rails']['db_host']} port=#{node['gitlab']['gitlab-rails']['db_port']} password=#{node['gitlab']['gitlab-rails']['db_password']}"
                     end

redis_url = redis_helper.redis_url(support_sentinel_groupname: false)

template "#{gitlab_exporter_dir}/gitlab-exporter.yml" do
  source "gitlab-exporter.yml.erb"
  owner gitlab_user
  mode "0600"
  notifies :restart, "runit_service[gitlab-exporter]"
  variables(
    probe_sidekiq: node['monitoring']['gitlab-exporter']['probe_sidekiq'],
    redis_url: redis_url,
    connection_string: connection_string,
    redis_enable_client: node['gitlab']['gitlab-rails']['redis_enable_client']
  )
end

# If a version of ruby changes restart gitlab-exporter
file File.join(gitlab_exporter_dir, 'RUBY_VERSION') do
  content VersionHelper.version('/opt/gitlab/embedded/bin/ruby --version')
  notifies :restart, 'runit_service[gitlab-exporter]'
end

runit_service "gitlab-exporter" do
  options({
    log_directory: gitlab_exporter_log_dir
  }.merge(params))
  log_options node['gitlab']['logging'].to_hash.merge(node['monitoring']['gitlab-exporter'].to_hash)
end

if node['gitlab']['bootstrap']['enable']
  execute "/opt/gitlab/bin/gitlab-ctl start gitlab-exporter" do
    retries 20
  end
end
