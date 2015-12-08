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
      end

      private

      def open_file
        @f = open(@options.fetch('path'), 'a')
      end
    end
  end
end
