require 'itamae'

module Itamae
  class Notification < Struct.new(:defined_in_resource, :action, :target_resource_desc, :timing)
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
  end

  class Subscription < Notification
    def action_resource
      defined_in_resource
    end
  end
end
