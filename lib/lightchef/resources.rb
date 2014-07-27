require 'lightchef'
require 'lightchef/resources/base'
require 'lightchef/resources/package'
require 'lightchef/resources/file'
require 'lightchef/resources/directory'

module Lightchef
  module Resources
    Error = Class.new(StandardError)
    CommandExecutionError = Class.new(StandardError)

    def self.get_resource_class_name(method)
      method.to_s.split('_').map {|part| part.capitalize}.join
    end

    def self.get_resource_class(method)
      const_get(get_resource_class_name(method))
    end
  end
end
