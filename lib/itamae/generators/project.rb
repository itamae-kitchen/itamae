require 'thor'
require 'thor/group'

module Itamae
  module Generators
    class Project < Thor::Group
      include Thor::Actions

      def self.source_root
        File.dirname(__FILE__) + '/templates/project'
      end

      def copy_files
        directory '.'
      end

      def bundle
        run 'bundle install'
      end
    end
  end
end
