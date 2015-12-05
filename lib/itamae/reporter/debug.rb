module Itamae
  module Reporter
    class Debug < Base
      def event(type, payload = {})
        Itamae.logger.info("EVENT:#{type} #{payload}")
      end
    end
  end
end
