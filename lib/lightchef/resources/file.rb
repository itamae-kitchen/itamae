require 'lightchef'

module Lightchef
  module Resources
    class File < Base
      define_option :action, default: :create
      define_option :source, type: String, required: true
      define_option :path, type: String, default_name: true

      def create_action
        src = ::File.expand_path(source, ::File.dirname(@recipe.path))
        copy_file(src, path)
      end
    end
  end
end

