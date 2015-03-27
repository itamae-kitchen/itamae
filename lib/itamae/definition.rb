require 'itamae'

module Itamae
  class Definition < Resource::Base
    class << self
      attr_accessor :definition_block
      attr_accessor :defined_in_recipe

      def create_class(name, params, defined_in_recipe, &block)
        Class.new(self).tap do |klass|
          klass.definition_block = block
          klass.defined_in_recipe = defined_in_recipe

          klass.define_attribute :action, default: :run
          params.each_pair do |key, value|
            klass.define_attribute key.to_sym, type: Object, default: value
          end
        end
      end
    end

    def initialize(*args)
      super

      # construct_resources
      r = Recipe.new(
        runner,
        recipe.path,
        &(self.class.definition_block)
      )

      # recipe.children << r
    end

    def action_run(options)
      # @children.run(options)
    end

    private

    def construct_resources
      block = self.class.definition_block

      context = Context.new(self, @attributes.merge(name: resource_name))
      context.instance_exec(&block)
      @children = context.children
    end

    class Context
      attr_reader :params
      attr_reader :children

      def initialize(definition, params, &block)
        @definition = definition
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
        resource = klass.new(@definition.recipe, name, &block)
        @children << resource
      end

      def node
        @definition.recipe.runner.node
      end
    end
  end
end

