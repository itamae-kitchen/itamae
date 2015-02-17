require 'itamae'
require 'erb'
require 'tempfile'

module Itamae
  module Resource
    class Template < File
      define_attribute :source, type: String, required: true
      define_attribute :variables, type: Hash, default: {}

      def pre_action
        src = ::File.expand_path(attributes.source, ::File.dirname(@recipe.path))
        attributes.content = RenderContext.new(self).render_file(src)

        super
      end

      class RenderContext
        def initialize(resource)
          @resource = resource

          @resource.attributes.variables.each_pair do |key, value|
            instance_variable_set("@#{key}".to_sym, value)
          end
        end

        def render_file(src)
          template = ::File.read(src)
          ERB.new(template, nil, '-').tap do |erb|
            erb.filename = src
          end.result(binding)
        end

        def node
          @resource.recipe.runner.node
        end
      end
    end
  end
end

