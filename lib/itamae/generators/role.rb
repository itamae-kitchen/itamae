require 'thor'
require 'thor/group'

module Itamae
  module Generators
    class Role < Thor::Group
      include Thor::Actions

      def self.source_root
        File.expand_path('../templates/role', __FILE__)
      end

      def copy_files
        directory '.'
      end

      def remove_files
        remove_file '.'
      end
    end
  end
end
