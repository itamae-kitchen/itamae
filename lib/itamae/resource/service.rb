require 'itamae'

module Itamae
  module Resource
    class Service < Base
      define_attribute :action, default: :nothing
      define_attribute :name, type: String, default_name: true

      def pre_action
        case @current_action
        when :start, :restart
          attributes.running = true
        when :stop
          attributes.running = false
        when :enable
          attributes.enabled = true
        when :disable
          attributes.enabled = false
        end
      end

      def set_current_attributes
        current.running = run_specinfra(:check_service_is_running, name)
        current.enabled = run_specinfra(:check_service_is_enabled, name)
      end

      def action_start(options)
        run_specinfra(:start_service, name)
      end

      def action_stop(options)
        run_specinfra(:stop_service, name)
      end

      def action_restart(options)
        run_specinfra(:restart_service, name)
      end

      def action_reload(options)
        run_specinfra(:reload_service, name)
      end

      def action_enable(options)
        run_specinfra(:enable_service, name)
      end

      def action_disable(options)
        run_specinfra(:disable_service, name)
      end
    end
  end
end

