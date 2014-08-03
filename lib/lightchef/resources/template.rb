require 'lightchef'
require 'erb'
require 'tempfile'

module Lightchef
  module Resources
    class Template < Base
      define_option :action, default: :create
      define_option :source, type: String, required: true
      define_option :path, type: String, default_name: true

      def create_action
        src = ::File.expand_path(source, ::File.dirname(@recipe.path))
        rendered = nil
        Tempfile.open('lightchef') do |f|
          f.write ERB.new(File.read(src), nil, '-').result(binding)
          rendered = f.path
        end
        copy_file(rendered, path)
      end
    end
  end
end

