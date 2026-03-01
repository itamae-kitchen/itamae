require 'itamae/handler/base'

module Itamae
  module Handler
    def self.from_type(type)
      unless type.match?(/\A[a-z_][a-z0-9_]*\z/)
        raise "Invalid handler type: #{type}"
      end
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
