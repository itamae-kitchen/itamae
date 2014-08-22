module Itamae
  class RecipeDependencies < Array
    NotFoundError = Class.new(StandardError)

    def find_resource_by_description(desc)
      # desc is like 'resource_type[name]'
      resources.find do |resource|
        type, name = Itamae::Resource.parse_description(desc)
        resource.resource_type == type && resource.resource_name == name
      end.tap do |resource|
        unless resource
          raise NotFoundError, "'#{desc}' resource is not found."
        end
      end
    end

    def subscribing(target)
      resources.map do |resource|
        resource.subscribes_resources.map do |action, r, timing|
          if r == target
            [action, resource, timing]
          end
        end.compact
      end.flatten(1)
    end

    def find_recipe_by_path(path)
      recipes(true).find do |recipe|
        recipe.path == path
      end
    end

    def resources
      self.select do |item|
        item.is_a?(Resource::Base)
      end
    end

    def recipes(recursive = false)
      self.select do |item|
        item.is_a?(Recipe)
      end.map do |recipe|
        [recipe] + recipe.dependencies.recipes(recursive)
      end.flatten
    end

    def run(options)
      self.each do |resource|
        case resource
        when Resource::Base
          resource.run(nil, dry_run: options[:dry_run])
        when Recipe
          resource.run(options)
        end
      end
    end
  end
end
