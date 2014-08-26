require 'itamae'

module Itamae
  module Resource
    class LocalRubyBlock < Base
      define_attribute :action, default: :run
      define_attribute :block, type: Proc

      def run_action(options)
        block.call
      end
    end
  end
end

