require_relative "resource/base"
require_relative "resource/file"
require_relative "resource/package"
require_relative "resource/remote_directory"
require_relative "resource/remote_file"
require_relative "resource/directory"
require_relative "resource/template"
require_relative "resource/http_request"
require_relative "resource/execute"
require_relative "resource/service"
require_relative "resource/link"
require_relative "resource/local_ruby_block"
require_relative "resource/git"
require_relative "resource/user"
require_relative "resource/group"
require_relative "resource/gem_package"

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
            autoload_plugin_resource(method)
          end
        end
      end

      def autoload_plugin_resource(method)
        begin
          require_relative "plugin/resource/#{method}"
          ::Itamae::Plugin::Resource.const_get(to_camel_case(method.to_s))
        rescue LoadError, NameError
          raise Error, "#{method} resource is missing."
        end
      end

      def define_resource(name, klass)
        class_name = to_camel_case(name.to_s)
        if Resource.const_defined?(class_name)
          Itamae.logger.warn "Redefine class. (#{class_name})"
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
