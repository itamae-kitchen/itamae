require 'lightchef'
require 'lightchef/resources/base'
require 'lightchef/resources/package'
require 'lightchef/resources/file'

module Lightchef
  module Resources
    def self.get_resource_class(method)
      name = method.to_s.split('_').map {|part| part.capitalize}.join
      const_get(name)
    end
  end
end
