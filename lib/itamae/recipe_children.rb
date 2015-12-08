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

    def run
      self.each do |resource|
        resource.run
      end
    end

    # returns dependencies graph in DOT
    def dependency_in_dot
      result = ""
      result << "digraph recipes {\n"
      result << "  rankdir=LR;\n"
      result << _dependency_in_dot
      result << "}"

      result
    end

    def _dependency_in_dot
      result = ""

      recipes(recursive: false).each do |recipe|
        recipe.children.recipes(recursive: false).each do |child_recipe|
          result << %{  "#{recipe.path}" -> "#{child_recipe.path}";\n}
        end
        result << recipe.children._dependency_in_dot
      end

      result
    end
  end
end
