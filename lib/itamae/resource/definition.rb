require 'itamae/resource/base'

module Itamae
  module Resource
    class Definition < Base
      class << self
        def definition_block
          value = class_variable_get(:@@definition_block) if class_variable_defined?(:@@definition_block)
          value
        end

        def definition_block=(value)
          class_variable_set(:@@definition_block, value)
        end

        def define_resource(&block)
          self.definition_block = block
        end
      end

      def initialize(*args)
        super

        r = Recipe::RecipeFromDefinition.new(
          runner,
          recipe.path,
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
end
