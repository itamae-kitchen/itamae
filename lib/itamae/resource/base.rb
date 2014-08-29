require 'itamae'
require 'shellwords'

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

      attr_reader :only_if_command
      attr_reader :not_if_command

      attr_reader :subscriptions
      attr_reader :notifications

      def initialize(recipe, resource_name, &block)
        @recipe = recipe
        @resource_name = resource_name

        @attributes = {}
        @updated = false
        @notifications = []
        @subscriptions = []

        instance_eval(&block) if block_given?
      end

      def converger
        converger_class.new(self)
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

      def updated!
        unless @updated
          Logger.debug "This resource is updated."
        end
        @updated = true
      end

      def updated?
        @updated
      end

      def subscriptions_to_me
        recipe.children.subscribing(self)
      end

      private

      def converger_class
        ::Itamae::Converger.const_get(self.class.name.split("::").last)
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

      def only_if(command)
        @only_if_command = command
      end

      def not_if(command)
        @not_if_command = command
      end

      def notifies(action, resource_desc, timing = :delay)
        @notifications << Notification.new(recipe.runner, self, action, resource_desc, timing)
      end

      def subscribes(action, resource_desc, timing = :delay)
        @subscriptions << Subscription.new(recipe.runner, self, action, resource_desc, timing)
      end

      def node
        recipe.runner.node
      end
    end
  end
end

