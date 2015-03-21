require 'itamae'
require 'logger'
require 'ansi/code'

module Itamae
  module Logger
    class Formatter
      attr_accessor :colored
      attr_accessor :depth
      attr_accessor :color

      INDENT_LENGTH = 2

      def initialize(*args)
        super

        @depth = 0
      end

      def call(severity, datetime, progname, msg)
        log = "%s : %s%s\n" % ["%5s" % severity, ' ' * INDENT_LENGTH * depth , msg2str(msg)]
        if colored
          colorize(log, severity)
        else
          log
        end
      end

      def with_indent
        indent
        yield
      ensure
        outdent
      end

      def with_indent_if(condition, &block)
        if condition
          with_indent(&block)
        else
          block.call
        end
      end

      def indent
        @depth += 1
      end

      def outdent
        @depth -= 1
        @depth = 0 if @depth < 0
      end

      def color(code)
        prev_color = @color
        @color = code
        yield
      ensure
        @color = prev_color
      end

      private
      def msg2str(msg)
        case msg
        when ::String
          msg
        when ::Exception
          "#{ msg.message } (#{ msg.class })\n" <<
          (msg.backtrace || []).join("\n")
        else
          msg.inspect
        end
      end

      def colorize(str, severity)
        if @color
          color_code = @color
        else
          color_code = case severity
                       when "INFO"
                         :clear
                       when "WARN"
                         :magenta
                       when "ERROR"
                         :red
                       else
                         :clear
                       end
        end
        ANSI.public_send(color_code) { str }
      end
    end

    class << self
      def logger
        @logger ||= create_logger
      end

      def log_device
        @log_device || $stdout
      end

      def log_device=(value)
        @log_device = value
        @logger = create_logger
      end

      private

      def create_logger
        ::Logger.new(log_device).tap do |logger|
          logger.formatter = Formatter.new
        end
      end

      def respond_to_missing?(method, include_private = false)
        logger.respond_to?(method)
      end

      def method_missing(method, *args, &block)
        logger.public_send(method, *args, &block)
      end
    end
  end
end

