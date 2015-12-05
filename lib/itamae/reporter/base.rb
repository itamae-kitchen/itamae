module Itamae
  module Reporter
    class Base
      def initialize(options)
      end

      def event(type, payload = {})
        raise NotImplementedError
      end
    end
  end
end
