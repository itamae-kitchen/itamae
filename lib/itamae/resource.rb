require 'itamae'
require 'itamae/resource/base'
require 'itamae/resource/file'
require 'itamae/resource/package'
require 'itamae/resource/remote_file'
require 'itamae/resource/directory'
require 'itamae/resource/template'
require 'itamae/resource/execute'
require 'itamae/resource/mail_alias'

module Itamae
  module Resource
    Error = Class.new(StandardError)
    CommandExecutionError = Class.new(StandardError)
    AttributeMissingError = Class.new(StandardError)
    InvalidTypeError = Class.new(StandardError)
    ParseError = Class.new(StandardError)

    class << self
      def get_resource_class_name(method)
        method.to_s.split('_').map {|part| part.capitalize}.join
      end

      def get_resource_class(method)
        const_get(get_resource_class_name(method))
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
