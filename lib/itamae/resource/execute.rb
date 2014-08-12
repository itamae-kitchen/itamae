require 'itamae'

module Itamae
  module Resource
    class Execute < Base
      define_option :action, default: :run
      define_option :command, type: String, default_name: true

      def run_action
        run_command(command)
      end
    end
  end
end

