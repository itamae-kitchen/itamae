require 'itamae'
require 'shellwords'
require 'hashie'

module Itamae
  module Resource
    class Base
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

      def initialize(recipe, resource_name, &block)
        @attributes = Hashie::Mash.new
        @current_attributes = Hashie::Mash.new
        @recipe = recipe
        @resource_name = resource_name
        @notifications = []
        @subscriptions = []
        @updated = false

        instance_eval(&block) if block_given?

        process_attributes
      end

      def run(specific_action = nil, options = {})
        attributes_without_action = attributes.dup.tap {|attr| attr.delete(:action) }
        Logger.info "#{resource_type} (#{attributes_without_action})..."

        Logger.formatter.indent do
          if do_not_run_because_of_only_if?
            Logger.info "Execution skipped because of only_if attribute"
            return
          elsif do_not_run_because_of_not_if?
            Logger.info "Execution skipped because of not_if attribute"
            return
          end

          [specific_action || action].flatten.each do |action|
            run_action(action, options)
          end

          updated! if different?

          notify(options) if updated?
        end
      rescue Backend::CommandExecutionError
        Logger.error "Failed."
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

      def run_action(action, options)
        @current_action = action

        Logger.info "action: #{action}"

        return if action == :nothing

        Logger.formatter.indent do
          Logger.debug "(in pre_action)"
          pre_action

          Logger.debug "(in set_current_attributes)"
          set_current_attributes

          Logger.debug "(in show_differences)"
          show_differences

          unless options[:dry_run]
            public_send("action_#{action}".to_sym, options)
          end
        end

        @current_action = nil
      end

      def respond_to_missing?(method, include_private = false)
        self.class.defined_attributes.has_key?(method) || super
      end

      def method_missing(method, *args, &block)
        if self.class.defined_attributes[method]
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

      def pre_action
        # do nothing
      end

      def set_current_attributes
        # do nothing
      end

      def different?
        @current_attributes.each_pair.any? do |key, current_value|
          current_value &&
            @attributes[key] &&
            current_value != @attributes[key]
        end
      end

      def show_differences
        @current_attributes.each_pair do |key, current_value|
          value = @attributes[key]
          if current_value.nil? && value.nil?
            # ignore
          elsif current_value.nil? && !value.nil?
            Logger.info "#{key} will be '#{value}'"
          elsif current_value == value || value.nil?
            Logger.debug "#{key} will not change (current value is '#{current_value}')"
          else
            Logger.info "#{key} will change from '#{current_value}' to '#{value}'"
          end
        end
      end

      def process_attributes
        self.class.defined_attributes.each_pair do |key, details|
          @attributes[key] ||= @resource_name if details[:default_name]
          @attributes[key] ||= details[:default] if details[:default]

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

      def only_if(command)
        @only_if_command = command
      end

      def not_if(command)
        @not_if_command = command
      end

      def do_not_run_because_of_only_if?
        @only_if_command &&
          run_command(@only_if_command, error: false).exit_status != 0
      end

      def do_not_run_because_of_not_if?
        @not_if_command &&
          run_command(@not_if_command, error: false).exit_status == 0
      end

      def notifies(action, resource_desc, timing = :delay)
        @notifications << Notification.new(runner, self, action, resource_desc, timing)
      end

      def subscribes(action, resource_desc, timing = :delay)
        @subscriptions << Subscription.new(runner, self, action, resource_desc, timing)
      end

      def node
        runner.node
      end

      def backend
        Backend.instance
      end

      def runner
        @recipe.runner
      end

      def run_command(*args)
        unless args.last.is_a?(Hash)
          args << {}
        end

        args.last[:user] ||= user

        backend.run_command(*args)
      end

      def check_command(*args)
        unless args.last.is_a?(Hash)
          args << {}
        end

        args.last[:error] = false

        run_command(*args).exit_status == 0
      end

      def run_specinfra(*args)
        backend.run_specinfra(*args)
      end

      def shell_escape(str)
        Shellwords.escape(str)
      end

      def updated!
        unless @updated
          Logger.debug "This resource is updated."
        end
        @updated = true
      end

      def updated?
        @updated
      end

      def notify(options)
        (notifications + recipe.children.subscribing(self)).each do |notification|
          message = "Notifying #{notification.action} to #{notification.action_resource.resource_type} resource '#{notification.action_resource.resource_name}'"

          case notification.timing
          when :delay
            message << " (delayed)"
          when :immediately
            message << " (immediately)"
          end

          Logger.info message

          if notification.instance_of?(Subscription)
            Logger.info "(because it subscribes this resource)"
          end

          case notification.timing
          when :immediately
            notification.run(options)
          when :delay
            @recipe.delayed_notifications << notification
          end
        end
      end
    end
  end
end

