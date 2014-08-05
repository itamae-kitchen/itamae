require 'itamae'

module Itamae
  module Resources
    class RemoteFile < File
      define_option :source, type: String, required: true

      def create_action
        content_file(::File.expand_path(source, ::File.dirname(@recipe.path)))

        super
      end
    end
  end
end

