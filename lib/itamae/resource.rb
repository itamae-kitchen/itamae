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
require 'itamae/resource/gem_package'

module Itamae
  module Resource
    Error = Class.new(StandardError)
    AttributeMissingError = Class.new(StandardError)
    InvalidTypeError = Class.new(StandardError)
    ParseError = Class.new(StandardError)

    class << self
      def to_camel_case(str)
        str.split('_').map {|part| part.capitalize}.join
      end

      def get_resource_class(method)
        begin
          self.const_get(to_camel_case(method.to_s))
        rescue NameError
          begin
            ::Itamae::Plugin::Resource.const_get(to_camel_case(method.to_s))
          rescue NameError
            raise Error, "#{method} resource is missing."
          end
        end
      end

      def define_resource(name, klass)
        class_name = to_camel_case(name.to_s)
        if Resource.const_defined?(class_name)
          Logger.warn "Redefine class. (#{class_name})"
          return
        end

        Resource.const_set(class_name, klass)
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
