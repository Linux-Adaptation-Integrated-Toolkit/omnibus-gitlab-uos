require 'io/console'
require 'rainbow/ext/string'

module Geo
  class PromoteToPrimary
    def initialize(base_path, options)
      @base_path = base_path
      @options = options
    end

    def execute
      make_sure_primary_is_down

      promote_postgresql_to_primary

      reconfigure

      promote_to_primary

      success_message
    end

    private

    def make_sure_primary_is_down
      return true if @options[:confirm_primary_is_down]

      puts
      puts '---------------------------------------'.color(:yellow)
      puts 'WARNING: Make sure your primary is down'.color(:yellow)
      puts 'If you have more than one secondary please see https://docs.gitlab.com/ee/gitlab-geo/disaster-recovery.html#promoting-secondary-geo-replica-in-multi-secondary-configurations'.color(:yellow)
      puts 'There may be data saved to the primary that was not been replicated to the secondary before the primary went offline. This data should be treated as lost if you proceed.'.color(:yellow)
      puts '---------------------------------------'.color(:yellow)
      puts

      print '*** Are you sure? (N/y): '.color(:green)

      raise 'Exited because primary node must be down' unless STDIN.gets.chomp.casecmp('y').zero?
    end

    def promote_postgresql_to_primary
      puts
      puts 'Promoting the PostgreSQL to primary...'.color(:yellow)
      puts

      run_command("/opt/gitlab/embedded/bin/gitlab-pg-ctl promote", live: true).error!
    end

    def reconfigure
      puts
      puts 'Reconfiguring...'.color(:yellow)
      puts

      run_command('gitlab-ctl reconfigure', live: true)
    end

    def promote_to_primary
      puts
      puts 'Running gitlab-rake geo:set_secondary_as_primary...'.color(:yellow)
      puts

      run_command('gitlab-rake geo:set_secondary_as_primary', live: true)
    end

    def success_message
      puts
      puts 'You successfully promoted this node!'.color(:green)
    end

    def run_command(cmd, live: false)
      GitlabCtl::Util.run_command(cmd, live: live)
    end
  end
end
