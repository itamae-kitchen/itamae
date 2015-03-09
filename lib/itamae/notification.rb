require 'itamae'

module Itamae
  class Notification < Struct.new(:defined_in_resource, :action, :target_resource_desc, :timing)
    def self.create(*args)
      self.new(*args).tap(&:validate!)
    end

    def resource
      runner.children.find_resource_by_description(target_resource_desc)
    end

    def run(options)
      action_resource.run(action, options)
    end

    def action_resource
      resource
    end

    def runner
      defined_in_resource.recipe.runner
    end

    def delayed?
      [:delay, :delayed].include?(timing)
    end

    def immediately?
      timing == :immediately
    end

    def validate!
      unless [:delay, :delayed, :immediately].include?(timing)
        Logger.error "'#{timing}' is not valid notification timing. (Valid option is delayed or immediately)"
        abort
      end
    end
  end

  class Subscription < Notification
    def action_resource
      defined_in_resource
    end
  end
end
