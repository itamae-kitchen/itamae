require 'itamae'

module Itamae
  class Notification
    attr_accessor :action
    attr_accessor :target_resource_desc
    attr_accessor :timing

    def initialize(runner, defined_in_resource, options)
      @runner = runner
      @defined_in_resource = defined_in_resource

      @action = options[:action]
      @target_resource_desc = options[:target_resource_desc]
      @timing = options[:timing]
    end

    def resource
      @runner.children.find_resource_by_description(target_resource_desc)
    end

    def run(options)
      action_resource.run(action, options)
    end

    def action_resource
      resource
    end
  end

  class Subscription < Notification
    def action_resource
      @defined_in_resource
    end
  end
end
