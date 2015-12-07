module Itamae
  module Reporter
    class Base
      def initialize(options)
        @options = options
      end

      def event(type, payload = {})
        raise NotImplementedError
      end
    end
  end
end
