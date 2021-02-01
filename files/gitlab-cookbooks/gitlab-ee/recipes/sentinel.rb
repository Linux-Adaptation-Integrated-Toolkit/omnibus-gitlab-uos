#
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

sentinel_helper = SentinelHelper.new(node)
sentinel_cfg = node['gitlab']['sentinel'].to_hash.merge({ 'myid' => sentinel_helper.myid })

sentinel_service 'redis' do
  config_path File.join(node['gitlab']['sentinel']['dir'], 'sentinel.conf')
  redis_configuration node['redis']
  sentinel_configuration sentinel_cfg
  logging_configuration node['gitlab']['logging']
end
