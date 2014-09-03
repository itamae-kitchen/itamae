require 'itamae'

module Itamae
  module Resource
    class LocalRubyBlock < Base
      define_attribute :action, default: :run
      define_attribute :block, type: Proc

      def action_run(options)
        attributes.block.call
      end
    end
  end
end

