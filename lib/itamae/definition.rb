require 'itamae'

module Itamae
  class Definition < Resource::Base
    class << self
      def create_class(name, params, &block)
        Class.new(self).tap do |klass|
          klass.definition_block = block

          klass.define_attribute :action, default: :run
          params.each_pair do |key, value|
            klass.define_attribute key.to_sym, type: Object, default: value
          end
        end
      end

      def definition_block=(block)
        @definition_block = block
      end

      def definition_block
        @definition_block
      end
    end

    def initialize(*args)
      super

      construct_resources
    end
    
    def action_run(options)
      @children.run(options)
    end

    private

    def construct_resources
      block = self.class.definition_block

      context = Context.new(@attributes.merge(name: resource_name))
      context.instance_exec(&block)
      @children = context.children
    end

    class Context
      attr_reader :params
      attr_reader :children

      def initialize(params, &block)
        @params = params
        @children = RecipeChildren.new
      end

      def respond_to_missing?(method, include_private = false)
        Resource.get_resource_class(method)
        true
      rescue NameError
        false
      end

      def method_missing(method, name, &block)
        klass = Resource.get_resource_class(method)
        resource = klass.new(self, name, &block)
        @children << resource
      end
    end
  end
end

