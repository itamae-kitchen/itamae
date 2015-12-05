require 'itamae/reporter/base'
require 'itamae/reporter/debug'

module Itamae
  module Reporter
    def self.from_type(type)
      class_name = type.split('_').map(&:capitalize).join
      self.const_get(class_name)
    end
  end
end
