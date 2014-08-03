require 'lightchef'
require 'lightchef/resources/base'
require 'lightchef/resources/file'
require 'lightchef/resources/package'
require 'lightchef/resources/remote_file'
require 'lightchef/resources/directory'
require 'lightchef/resources/template'

module Lightchef
  module Resources
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
