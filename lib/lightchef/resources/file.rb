require 'lightchef'

module Lightchef
  module Resources
    class File < Base
      def create_action
        src = ::File.expand_path(fetch_option(:source), ::File.dirname(@recipe.path))
        dst = fetch_option(:path)
        copy_file(src, dst)
      end
    end
  end
end

