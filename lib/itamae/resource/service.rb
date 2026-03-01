module Itamae
  module Resource
    class Service < Base
      define_attribute :action, default: :nothing
      define_attribute :name, type: String, default_name: true
      define_attribute :provider, type: Symbol, default: nil

      VALID_PROVIDERS = [:systemd, :upstart, :sysvinit].freeze

      def initialize(*args)
        super
        @under = if attributes.provider
                   unless VALID_PROVIDERS.include?(attributes.provider)
                     raise ArgumentError, "Invalid service provider '#{attributes.provider}'. Valid: #{VALID_PROVIDERS.join(', ')}"
                   end
                   "_under_#{attributes.provider}"
                 else
                   ""
                 end
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

