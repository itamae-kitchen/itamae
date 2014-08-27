require 'itamae'
require 'logger'
require 'ansi/code'

module Itamae
  module Logger
    class Formatter
      attr_accessor :colored

      def call(severity, datetime, progname, msg)

        severity = if colored
                     color("%5s" % severity, severity)
                   else
                     "%5s" % severity
                   end

        "%s : %s\n" % [severity, msg2str(msg)]
      end

      private
      def format_datetime(time)
        time.strftime("%Y-%m-%dT%H:%M:%S%:z")
      end

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

      def color(str, severity)
        color_code = case severity
                     when "INFO"
                       :green
                     when "WARN"
                       :magenta
                     when "ERROR"
                       :red
                     else
                       :clear
                     end
        ANSI.public_send(color_code) { str }
      end
    end

    class << self
      def logger
        @logger ||= ::Logger.new($stdout).tap do |logger|
          logger.formatter = Formatter.new
        end
      end

      def logger=(l)
        @logger = l
      end

      def method_missing(method, *args, &block)
        logger.public_send(method, *args, &block)
      end
    end
  end
end

