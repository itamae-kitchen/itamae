require 'itamae'

module Itamae
  module Resource
    class Execute < Base
      define_attribute :action, default: :run
      define_attribute :command, type: String, default_name: true
      define_attribute :cwd, type: String

      def action_run(options)
        run_command(attributes.command, cwd: attributes.cwd)
        updated!
      end
    end
  end
end

