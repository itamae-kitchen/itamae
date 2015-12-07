module Itamae
  module Reporter
    class Base
      def initialize(options)
        @options = options

        @recipes = []
        @resources = []
        @actions = []
      end

      def event(type, payload = {})
        case type
        when :recipe_started
          @recipes << payload
        when :recipe_completed, :recipe_failed
          @recipes.pop
        when :resource_started
          @resources << payload
        when :resource_completed, :resource_failed
          @resources.pop
        when :action_started
          @actions << payload
        when :action_completed, :action_failed
          @actions.pop
        end
      end
    end
  end
end
