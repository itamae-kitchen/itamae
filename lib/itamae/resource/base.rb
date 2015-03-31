require 'itamae'
require 'shellwords'
require 'hashie'

module Itamae
  module Resource
    class Base
      class EvalContext
        attr_reader :attributes
        attr_reader :notifications
        attr_reader :subscriptions
        attr_reader :verify_commands
        attr_reader :only_if_command
        attr_reader :not_if_command

        def initialize(resource)
          @resource = resource

          @attributes = Hashie::Mash.new
          @notifications = []
          @subscriptions = []
          @verify_commands = []
        end

        def respond_to_missing?(method, include_private = false)
          @resource.class.defined_attributes.has_key?(method) || super
        end

        def method_missing(method, *args, &block)
          if @resource.class.defined_attributes[method]
            if args.size == 1
              return @attributes[method] = args.first
            elsif args.size == 0 && block_given?
              return @attributes[method] = block
            elsif args.size == 0
              return @attributes[method]
            end
          end

          super
        end

        def notifies(action, resource_desc, timing = :delay)
          @notifications << Notification.create(@resource, action, resource_desc, timing)
        end

        def subscribes(action, resource_desc, timing = :delay)
          @subscriptions << Subscription.create(@resource, action, resource_desc, timing)
        end

        def only_if(command)
          @only_if_command = command
        end

        def not_if(command)
          @not_if_command = command
        end

        def node
          @resource.recipe.runner.node
        end

        # Experimental
        def verify(command)
          @verify_commands << command
        end
      end

      @defined_attributes ||= {}

      class << self
        attr_reader :defined_attributes
        attr_reader :supported_oses

        def inherited(subclass)
          subclass.instance_variable_set(
            :@defined_attributes,
            self.defined_attributes.dup
          )
        end

        def define_attribute(name, options)
          current = @defined_attributes[name.to_sym] || {}
          @defined_attributes[name.to_sym] = current.merge(options)
        end
      end

      define_attribute :action, type: [Symbol, Array], required: true
      define_attribute :user, type: String

      attr_reader :recipe
      attr_reader :resource_name
      attr_reader :attributes
      attr_reader :current_attributes
      attr_reader :subscriptions
      attr_reader :notifications
      attr_reader :updated

      def initialize(recipe, resource_name, &block)
        clear_current_attributes
        @recipe = recipe
        @resource_name = resource_name
        @updated = false

        EvalContext.new(self).tap do |context|
          context.instance_eval(&block) if block
          @attributes = context.attributes
          @notifications = context.notifications
          @subscriptions = context.subscriptions
          @only_if_command = context.only_if_command
          @not_if_command = context.not_if_command
          @verify_commands = context.verify_commands
        end

        process_attributes
      end

      def run(specific_action = nil, options = {})
        Logger.debug "#{resource_type}[#{resource_name}]"

        Logger.formatter.with_indent_if(Logger.debug?) do
          if do_not_run_because_of_only_if?
            Logger.debug "#{resource_type}[#{resource_name}] Execution skipped because of only_if attribute"
            return
          elsif do_not_run_because_of_not_if?
            Logger.debug "#{resource_type}[#{resource_name}] Execution skipped because of not_if attribute"
            return
          end

          [specific_action || attributes.action].flatten.each do |action|
            run_action(action, options)
          end

          verify unless options[:dry_run]
          notify(options) if updated?
        end
      rescue Backend::CommandExecutionError
        Logger.error "#{resource_type}[#{resource_name}] Failed."
        exit 2
      end

      def action_nothing(options)
        # do nothing
      end

      def resource_type
        humps = []
        self.class.name.split("::").last.each_char do |c|
          if "A" <= c && c <= "Z"
            humps << c.downcase
          else
            humps.last << c
          end
        end
        humps.join('_')
      end

      private

      alias_method :current, :current_attributes

      def run_action(action, options)
        @current_action = action

        clear_current_attributes

        Logger.debug "#{resource_type}[#{resource_name}] action: #{action}"

        return if action == :nothing

        Logger.formatter.with_indent_if(Logger.debug?) do
          Logger.debug "(in pre_action)"
          pre_action

          Logger.debug "(in set_current_attributes)"
          set_current_attributes

          Logger.debug "(in show_differences)"
          show_differences

          unless options[:dry_run]
            public_send("action_#{action}".to_sym, options)
          end

          updated! if different?
        end

        @current_action = nil
      end

      def clear_current_attributes
        @current_attributes = Hashie::Mash.new
      end

      def pre_action
        # do nothing
      end

      def set_current_attributes
        # do nothing
      end

      def different?
        @current_attributes.each_pair.any? do |key, current_value|
          !current_value.nil? &&
            !@attributes[key].nil? &&
            current_value != @attributes[key]
        end
      end

      def show_differences
        @current_attributes.each_pair do |key, current_value|
          value = @attributes[key]
          if current_value.nil? && value.nil?
            # ignore
          elsif current_value.nil? && !value.nil?
            Logger.formatter.color :green do
              Logger.info "#{resource_type}[#{resource_name}] #{key} will be '#{value}'"
            end
          elsif current_value == value || value.nil?
            Logger.debug "#{resource_type}[#{resource_name}] #{key} will not change (current value is '#{current_value}')"
          else
            Logger.formatter.color :green do
              Logger.info "#{resource_type}[#{resource_name}] #{key} will change from '#{current_value}' to '#{value}'"
            end
          end
        end
      end

      def process_attributes
        self.class.defined_attributes.each_pair do |key, details|
          @attributes[key] ||= @resource_name if details[:default_name]
          @attributes[key] = details[:default] if details.has_key?(:default) && !@attributes.has_key?(key)

          if details[:required] && !@attributes[key]
            raise Resource::AttributeMissingError, "'#{key}' attribute is required but it is not set."
          end

          if @attributes[key] && details[:type]
            valid_type = [details[:type]].flatten.any? do |type|
              @attributes[key].is_a?(type)
            end
            unless valid_type
              raise Resource::InvalidTypeError, "#{key} attribute should be #{details[:type]}."
            end
          end
        end
      end

      def send_file(src, dst)
        Logger.debug "Sending a file from '#{src}' to '#{dst}'..."
        unless ::File.exist?(src)
          raise Error, "The file '#{src}' doesn't exist."
        end
        backend.send_file(src, dst)
      end

      def send_directory(src, dst)
        Logger.debug "Sending a directory from '#{src}' to '#{dst}'..."
        unless ::File.directory?(src)
          raise Error, "'#{src}' is not directory."
        end
        unless ::File.exist?(src)
          raise Error, "The directory '#{src}' doesn't exist."
        end
        backend.send_directory(src, dst)
      end

      def do_not_run_because_of_only_if?
        @only_if_command &&
          run_command(@only_if_command, error: false).exit_status != 0
      end

      def do_not_run_because_of_not_if?
        @not_if_command &&
          run_command(@not_if_command, error: false).exit_status == 0
      end

      def backend
        runner.backend
      end

      def runner
        recipe.runner
      end

      def node
        runner.node
      end

      def run_command(*args)
        unless args.last.is_a?(Hash)
          args << {}
        end

        args.last[:user] ||= attributes.user

        backend.run_command(*args)
      end

      def check_command(*args)
        unless args.last.is_a?(Hash)
          args << {}
        end

        args.last[:error] = false

        run_command(*args).exit_status == 0
      end

      def run_specinfra(type, *args)
        command = backend.get_command(type, *args)

        if type.to_s.start_with?("check_")
          check_command(command)
        else
          run_command(command)
        end
      end

      def shell_escape(str)
        Shellwords.escape(str)
      end

      def updated!
        Logger.debug "This resource is updated."
        @updated = true
      end

      def updated?
        @updated
      end

      def notify(options)
        (notifications + recipe.children.subscribing(self)).each do |notification|
          message = "Notifying #{notification.action} to #{notification.action_resource.resource_type} resource '#{notification.action_resource.resource_name}'"

          if notification.delayed?
            message << " (delayed)"
          elsif notification.immediately?
            message << " (immediately)"
          end

          Logger.info message

          if notification.instance_of?(Subscription)
            Logger.info "(because it subscribes this resource)"
          end

          if notification.delayed?
            @recipe.delayed_notifications << notification
          elsif notification.immediately?
            notification.run(options)
          end
        end
      end

      def verify
        return if @verify_commands.empty?

        Logger.info "Verifying..."
        Logger.formatter.with_indent do
          @verify_commands.each do |command|
            run_command(command)
          end
        end
      end
    end
  end
end

