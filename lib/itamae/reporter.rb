require 'itamae/reporter/base'
require 'itamae/reporter/debug'

module Itamae
  module Reporter
    def self.from_type(type)
      first_time = true

      class_name = type.split('_').map(&:capitalize).join
      self.const_get(class_name)
    rescue NameError
      require "itamae/reporter/#{type}"

      if first_time
        first_time = false
        retry
      else
        raise
      end
    end
  end
end
