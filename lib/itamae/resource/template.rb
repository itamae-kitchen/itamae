require 'itamae'
require 'erb'
require 'tempfile'

module Itamae
  module Resource
    class Template < File
      define_attribute :source, type: String, required: true

      def pre_action
        src = ::File.expand_path(attributes.source, ::File.dirname(@recipe.path))
        attributes.content = ERB.new(::File.read(src), nil, '-').result(binding)

        super
      end
    end
  end
end

