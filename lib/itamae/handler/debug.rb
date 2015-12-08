module Itamae
  module Handler
    class Debug < Base
      def event(type, payload = {})
        super
        Itamae.logger.info("EVENT:#{type} #{payload}")
      end
    end
  end
end
