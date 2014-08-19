require 'itamae'

module Itamae
  module Resource
    class Service < Base
      define_attribute :action, default: :nothing
      define_attribute :name, type: String, default_name: true

      def start_action
        run_init_script("start")
      end

      def stop_action
        run_init_script("stop")
      end

      def restart_action
        run_init_script("restart")
      end

      def reload_action
        run_init_script("reload")
      end

      private
      def run_init_script(command)
        # TODO: Delegate to Specinfra
        run_command([init_script_path, command])
      end

      def init_script_path
        "/etc/init.d/#{name}"
      end
    end
  end
end

