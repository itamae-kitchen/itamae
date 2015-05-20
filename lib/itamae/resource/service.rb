require 'itamae'

module Itamae
  module Resource
    class Service < Base
      define_attribute :action, default: :nothing
      define_attribute :name, type: String, default_name: true
      define_attribute :provider, type: Symbol, default: nil

      def initialize(*args)
        super
        @under = attributes.provider ? "_under_#{attributes.provider}" : ""
      end

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
        current.running = run_specinfra(:"check_service_is_running#{@under}", attributes.name)
        current.enabled = run_specinfra(:"check_service_is_enabled#{@under}", attributes.name)
      end

      def action_start(options)
        unless current.running
          run_specinfra(:"start_service#{@under}", attributes.name)
        end
      end

      def action_stop(options)
        if current.running
          run_specinfra(:"stop_service#{@under}", attributes.name)
        end
      end

      def action_restart(options)
        run_specinfra(:"restart_service#{@under}", attributes.name)
      end

      def action_reload(options)
        if current.running
          run_specinfra(:"reload_service#{@under}", attributes.name)
        end
      end

      def action_enable(options)
        unless current.enabled
          run_specinfra(:"enable_service#{@under}", attributes.name)
        end
      end

      def action_disable(options)
        if current.enabled
          run_specinfra(:"disable_service#{@under}", attributes.name)
        end
      end
    end
  end
end

