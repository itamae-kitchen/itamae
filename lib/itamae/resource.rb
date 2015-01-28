require 'itamae'
require 'itamae/resource/base'
require 'itamae/resource/file'
require 'itamae/resource/package'
require 'itamae/resource/remote_directory'
require 'itamae/resource/remote_file'
require 'itamae/resource/directory'
require 'itamae/resource/template'
require 'itamae/resource/execute'
require 'itamae/resource/service'
require 'itamae/resource/link'
require 'itamae/resource/local_ruby_block'
require 'itamae/resource/git'
require 'itamae/resource/user'
require 'itamae/resource/group'

module Itamae
  module Resource
    Error = Class.new(StandardError)
    AttributeMissingError = Class.new(StandardError)
    InvalidTypeError = Class.new(StandardError)
    ParseError = Class.new(StandardError)

    class << self
      def get_resource_class_name(method)
        to_camel_case(method.to_s)
      end

      def get_resource_plugin_class_name(method)
        '::Itamae::Plugin::Resource::' + to_camel_case(method.to_s)
      end

      def to_camel_case(str)
        str.split('_').map {|part| part.capitalize}.join
      end

      def get_resource_class(method)
        begin
          const_get(get_resource_class_name(method))
        rescue NameError => e
          const_get(get_resource_plugin_class_name(method))
        end
      end

      def parse_description(desc)
        if /\A([^\[]+)\[([^\]]+)\]\z/ =~ desc
          [$1, $2]
        else
          raise ParseError, "'#{desc}' doesn't represent a resource."
        end
      end
    end
  end
end
