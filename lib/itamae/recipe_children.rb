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

    def recipes(options = {})
      options = {recursive: true}.merge(options)

      self.select do |item|
        item.is_a?(Recipe)
      end.map do |recipe|
        if options[:recursive]
          [recipe] + recipe.children.recipes
        else
          recipe
        end
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

    # returns dependencies graph in DOT
    def deps_in_dot
      result = ""
      result << "digraph recipes {\n"
      result << "  rankdir=LR;\n"
      result << _deps_in_dot
      result << "}"

      result
    end

    def _deps_in_dot
      result = ""

      recipes(recursive: false).each do |recipe|
        recipe.children.recipes(recursive: false).each do |child_recipe|
          result << %{  "#{recipe.path}" -> "#{child_recipe.path}";\n}
        end
        result << recipe.children._deps_in_dot
      end

      result
    end
  end
end
