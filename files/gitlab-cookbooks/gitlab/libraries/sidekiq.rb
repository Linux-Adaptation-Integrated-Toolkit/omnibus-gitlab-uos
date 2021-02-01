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

module Sidekiq
  class << self
    CLUSTER_ATTRIBUTE_NAMES = %w(ha log_directory experimental_queue_selector
                                 interval max_concurrency min_concurrency negate
                                 queue_groups).freeze

    def parse_variables
      return if Gitlab['sidekiq']['enable'] == false
      # We only need to do special things when people are migrating
      # to sidekiq cluster
      return unless Gitlab['sidekiq']['cluster']

      if Gitlab['sidekiq_cluster']['enable']
        raise "Sidekiq cluster configured, please consider disabling it to try the "\
              "experimental sidekiq-cluster defaults."
      end

      Gitlab['sidekiq']['enable'] = false
      Gitlab['sidekiq_cluster']['enable'] = true

      Gitlab['sidekiq_cluster'].merge!(sidekiq_cluster_settings)

      # Set the concurrency based on the single `concurrency` setting if it was
      # present
      configured_concurrency = user_settings['concurrency']
      return unless configured_concurrency

      if configured_concurrency && user_configured_cluster_concurrency?
        raise "Cannot specify `concurrency` in combination with `min_concurrency` "\
              "and `max_concurrency`"
      end

      Gitlab['sidekiq_cluster']['min_concurrency'] =
        Gitlab['sidekiq_cluster']['max_concurrency'] =
          configured_concurrency
    end

    private

    def user_settings
      Gitlab['sidekiq']
    end

    def defaults
      Gitlab['node']['gitlab']['sidekiq']
    end

    def cluster_package_defaults
      defaults.to_hash.slice(*CLUSTER_ATTRIBUTE_NAMES)
    end

    def cluster_user_settings
      user_settings.slice(*CLUSTER_ATTRIBUTE_NAMES)
    end

    def sidekiq_cluster_settings
      cluster_package_defaults.slice(*CLUSTER_ATTRIBUTE_NAMES)
        .merge(cluster_user_settings)
    end

    def user_configured_cluster_concurrency?
      cluster_user_settings.key?('min_concurrency') ||
        cluster_user_settings.key?('max_concurrency')
    end
  end
end
