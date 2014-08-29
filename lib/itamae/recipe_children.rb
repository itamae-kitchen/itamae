module Itamae
  class RecipeChildren < Array
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
        resource.subscriptions.select do |subscription|
          subscription.resource == target
        end
      end.flatten
    end

    def find_recipe_by_path(path)
      recipes.find do |recipe|
        recipe.path == path
      end
    end

    def resources
      self.map do |item|
        case item
        when Resource::Base
          item
        when Recipe
          item.children.resources
        end
      end.flatten
    end

    def recipes
      self.select do |item|
        item.is_a?(Recipe)
      end.map do |recipe|
        [recipe] + recipe.children.recipes
      end.flatten
    end

    def run(options)
      self.each do |resource|
        case resource
        when Resource::Base
          resource.converger.run(nil, dry_run: options[:dry_run])
        when Recipe
          resource.run(options)
        end
      end
    end
  end
end
