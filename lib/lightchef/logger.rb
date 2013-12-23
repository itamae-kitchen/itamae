require 'lightchef'
require 'logger'

module Lightchef
  module Logger
    def self.logger
      @logger ||= ::Logger.new($stdout)
    end

    def self.logger=(l)
      @logger = l
    end

    def self.method_missing(method, *args, &block)
      logger.public_send(method, *args, &block)
    end
  end
end

