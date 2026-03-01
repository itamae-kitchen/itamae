module Itamae
  module Handler
    class Json < Base
      def initialize(*)
        super
        require 'time'
        open_file
      end

      def event(type, payload = {})
        super
        @f.puts({'time' => Time.now.iso8601, 'event' => type, 'payload' => payload}.to_json)
        @f.flush
      end

      def finalize
        @f.close if @f
      end

      private

      def open_file
        @f = File.open(@options.fetch('path'), 'a')
      end
    end
  end
end
