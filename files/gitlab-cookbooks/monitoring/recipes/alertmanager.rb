#
# Copyright:: Copyright (c) 2018 GitLab Inc.
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
prometheus_user = account_helper.prometheus_user
alertmanager_log_dir = node['monitoring']['alertmanager']['log_directory']
alertmanager_dir = node['monitoring']['alertmanager']['home']
alertmanager_static_etc_dir = node['monitoring']['alertmanager']['env_directory']

# alertmanager runs under the prometheus user account. If prometheus is
# disabled, it's up to this recipe to create the account
include_recipe 'monitoring::user'

directory alertmanager_dir do
  owner prometheus_user
  mode '0750'
  recursive true
end

directory alertmanager_log_dir do
  owner prometheus_user
  mode '0700'
  recursive true
end

directory alertmanager_static_etc_dir do
  owner prometheus_user
  mode '0700'
  recursive true
end

env_dir alertmanager_static_etc_dir do
  variables node['monitoring']['alertmanager']['env']
  notifies :restart, "runit_service[alertmanager]"
end

configuration = {
  'global' => node['monitoring']['alertmanager']['global'],
  'templates' => node['monitoring']['alertmanager']['templates'],
  'route' => {
    'receiver' => node['monitoring']['alertmanager']['default_receiver'],
    'routes' => node['monitoring']['alertmanager']['routes'],
  },
  'receivers' => node['monitoring']['alertmanager']['receivers'],
  'inhibit_rules' => node['monitoring']['alertmanager']['inhibit_rules'],
}

file 'Alertmanager config' do
  path File.join(alertmanager_dir, 'alertmanager.yml')
  content Prometheus.hash_to_yaml(configuration)
  owner prometheus_user
  mode '0644'
  notifies :restart, 'runit_service[alertmanager]'
end

runtime_flags = PrometheusHelper.new(node).kingpin_flags('alertmanager')
runit_service 'alertmanager' do
  options({
    log_directory: alertmanager_log_dir,
    flags: runtime_flags,
    env_dir: alertmanager_static_etc_dir
  }.merge(params))
  log_options node['gitlab']['logging'].to_hash.merge(
    node['monitoring']['alertmanager'].to_hash
  )
end

if node['gitlab']['bootstrap']['enable']
  execute "/opt/gitlab/bin/gitlab-ctl start alertmanager" do
    retries 20
  end
end
