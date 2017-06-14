require 'socket'
require 'lavigne/cucumber/id_provider'
module Lavigne
  module Cucumber
    # This class is responsible for providing the bits that tend to change
    # from one Cucumber version to another
    class BaseShim
      attr_accessor :run_info, :env_vars
      attr_writer :id_provider

      def id_provider
        @id_provider ||= default_id_provider
      end


      def default_id_provider
        IDProvider.new
      end

      def capture_env(opts = {})
        keys = opts.fetch(:only, ENV.keys) - opts.fetch(:except, [])
        @env_vars = keys.map { |name| { 'name' => name, 'value' => ENV[name] } }
        run_info['env'] = @env_vars unless run_info.nil?
      end

      def include_run_info(info)
        @run_info = info.dup
        @run_info['run_info_version'] = 1
        @run_info['start_time'] ||= Time.now.to_i
        @run_info['hostname'] ||= Socket.gethostname
        @run_info['env'] = env_vars unless env_vars.nil?
        @run_info
      end
    end
  end
end
