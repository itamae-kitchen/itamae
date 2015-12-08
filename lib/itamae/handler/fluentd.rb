module Itamae
  module Handler
    class Fluentd < Base
      attr_accessor :fluent_logger # for test

      def initialize(*)
        super
        load_fluent_logger
      end

      def event(type, payload = {})
        super

        unless @fluent_logger.post(type, payload.merge(hostname: hostname))
          Itamae.logger.warn "Sending logs to Fluentd failed: #{@fluent_logger.last_error}"
        end
      end

      private

      def load_fluent_logger
        begin
          require 'fluent-logger'
        rescue LoadError
          raise "Loading fluent-logger gem failed. Please install 'fluent-logger' gem to use fluentd handler."
        end

        @fluent_logger = Fluent::Logger::FluentLogger.new(tag_prefix, host: fluentd_host, port: fluentd_port)
      end

      def tag_prefix
        @options['tag_prefix'] || 'itamae_server'
      end

      def fluentd_host
        @options['host'] || 'localhost'
      end

      def fluentd_port
        (@options['port'] || 24224).to_i
      end
    end
  end
end
