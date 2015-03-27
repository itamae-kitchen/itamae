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

      r = Recipe::RecipeFromDefinition.new(
        runner,
        self.class.defined_in_recipe.path,
      )
      recipe.children << r

      r.definition = self
      r.load(params: @attributes.merge(name: resource_name))
    end

    def run(*args)
      # nothing
    end
  end
end

