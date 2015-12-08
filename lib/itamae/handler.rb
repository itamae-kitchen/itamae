require 'itamae/handler/base'

module Itamae
  module Handler
    def self.from_type(type)
      first_time = true

      class_name = type.split('_').map(&:capitalize).join
      self.const_get(class_name)
    rescue NameError
      require "itamae/handler/#{type}"

      if first_time
        first_time = false
        retry
      else
        raise
      end
    end
  end
end
