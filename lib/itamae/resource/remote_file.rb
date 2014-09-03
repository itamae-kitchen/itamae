require 'itamae'

module Itamae
  module Resource
    class RemoteFile < File
      define_attribute :source, type: String, required: true

      def pre_action
        attributes.content_file =
          ::File.expand_path(attributes.source, ::File.dirname(@recipe.path))

        super
      end
    end
  end
end

