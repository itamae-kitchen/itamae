require 'itamae'
require 'logger'
require 'ansi/code'

module Itamae
  module Logger
    module Helper
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
        self.indent_depth += 1
      end

      def outdent
        self.indent_depth -= 1
        self.indent_depth = 0 if self.indent_depth < 0
      end

      def indent_depth
        @indent_depth ||= 0
      end

      def indent_depth=(val)
        @indent_depth = val
      end

      def color(code, &block)
        if self.formatter.respond_to?(:color)
          self.formatter.color(code, &block)
        else
          block.call
        end
      end

      %w!debug info warn error fatal unknown!.each do |level|
        module_eval(<<-EOC, __FILE__, __LINE__ + 1)
          def #{level}(msg)
            super(indent_msg(msg))
          end
        EOC
      end

      private

      def indent_msg(msg)
        spaces = "  " * indent_depth
        case msg
        when ::String
          "#{spaces}#{msg}"
        when ::Exception
          "#{spaces}#{msg.message} (#{msg.class})\n" <<
          (msg.backtrace || []).map {|f| "#{spaces}#{f}"}.join("\n")
        else
          "#{spaces}#{msg.inspect}"
        end
      end
    end

    class Formatter
      attr_accessor :colored

      def call(severity, datetime, progname, msg)
        log = "%s : %s" % ["%5s" % severity, msg2str(msg)]

        (colored ? colorize(log, severity) : log) + "\n"
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
  end

  @logger = ::Logger.new($stdout).tap do |l|
    l.formatter = Itamae::Logger::Formatter.new
  end.extend(Itamae::Logger::Helper)

  class << self
    def logger
      @logger
    end

    def logger=(l)
      @logger = l.extend(Itamae::Logger::Helper)
    end
  end
end
