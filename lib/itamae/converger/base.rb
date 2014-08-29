require 'itamae'

module Itamae
  module Converger
    class Base
      attr_reader :resource
      attr_reader :current_resource

      def initialize(resource)
        @resource = resource
        @current_resource = resource.class.new(resource.recipe, resource.resource_name)
      end

      def run(specific_action = nil, options = {})
        attributes_without_action = resource.attributes.dup.tap {|attr| attr.delete(:action) }
        Logger.info "#{resource.resource_type} (#{attributes_without_action})..."

        Logger.formatter.indent do
          if do_not_run_because_of_only_if?
            Logger.info "Execution skipped because of only_if attribute"
            return
          elsif do_not_run_because_of_not_if?
            Logger.info "Execution skipped because of not_if attribute"
            return
          end

          [specific_action || resource.action].flatten.each do |action|
            @current_action = action

            Logger.info "action: #{action}"

            next if action == :nothing

            unless options[:dry_run]
              Logger.formatter.indent do
                Logger.debug "(in pre_action)"
                pre_action

                Logger.debug "(in set_current_attributes)"
                set_current_attributes

                Logger.debug "(in show_differences)"
                show_differences

                send("action_#{specific_action || action}".to_sym, options)
              end
            end

            @current_action = nil
          end

          updated! if different?

          notify(options) if resource.updated?
        end
      rescue Backend::CommandExecutionError
        Logger.error "Failed."
        exit 2
      end

      private

      def action_nothing(options)
        # do nothing
      end

      def pre_action
        # do nothing
      end

      def set_current_attributes
        # do nothing
      end

      def different?
        current_resource.attributes.each_pair.any? do |key, current_value|
          value_to_be = resource.attributes[key]
          current_value && value_to_be && current_value != value_to_be
        end
      end

      def show_differences
        current_resource.attributes.each_pair do |key, current_value|
          value = resource.attributes[key]
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

      def do_not_run_because_of_only_if?
        resource.only_if_command &&
          run_command(resource.only_if_command, error: false).exit_status != 0
      end

      def do_not_run_because_of_not_if?
        resource.not_if_command &&
          run_command(resource.not_if_command, error: false).exit_status == 0
      end

      def run_command(*args)
        unless args.last.is_a?(Hash)
          args << {}
        end

        args.last[:user] ||= resource.user

        Backend.instance.run_command(*args)
      end

      def check_command(*args)
        unless args.last.is_a?(Hash)
          args << {}
        end

        args.last[:error] = false

        run_command(*args).exit_status == 0
      end

      def run_specinfra(*args)
        Backend.instance.run_specinfra(*args)
      end

      def shell_escape(str)
        Shellwords.escape(str)
      end

      def send_file(src, dst)
        Logger.debug "Sending a file from '#{src}' to '#{dst}'..."
        unless ::File.exist?(src)
          raise Error, "The file '#{src}' doesn't exist."
        end
        Backend.instance.send_file(src, dst)
      end

      def notify(options)
        notifications = resource.notifications + resource.subscriptions_to_me
        notifications.each do |notification|
          case notification.timing
          when :immediately
            notification.run(options)
          when :delay
            resource.recipe.delayed_notifications << notification
          end
        end
      end
    end
  end
end

