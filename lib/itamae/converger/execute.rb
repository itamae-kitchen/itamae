require 'itamae'

module Itamae
  module Converger
    class Execute < Base
      def action_run(options)
        run_command(resource.command)
        resource.updated!
      end
    end
  end
end

