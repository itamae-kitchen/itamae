module Itamae
  module Resource
    class LocalRubyBlock < Base
      define_attribute :action, default: :run
      define_attribute :block, type: Proc

      def action_run(options)
        if attributes[:cwd]
          Dir.chdir(attributes[:cwd]) do
            attributes.block.call
          end
        else
          attributes.block.call
        end
      end
    end
  end
end

