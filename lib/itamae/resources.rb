require 'itamae'
require 'itamae/resources/base'
require 'itamae/resources/file'
require 'itamae/resources/package'
require 'itamae/resources/remote_file'
require 'itamae/resources/directory'
require 'itamae/resources/template'
require 'itamae/resources/execute'
require 'itamae/resources/mail_alias'

module Itamae
  module Resource
    Error = Class.new(StandardError)
    CommandExecutionError = Class.new(StandardError)
    OptionMissingError = Class.new(StandardError)
    InvalidTypeError = Class.new(StandardError)
    NotSupportedOsError = Class.new(StandardError)

    def self.get_resource_class_name(method)
      method.to_s.split('_').map {|part| part.capitalize}.join
    end

    def self.get_resource_class(method)
      const_get(get_resource_class_name(method))
    end
  end
end
