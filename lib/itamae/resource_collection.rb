module Itamae
  class ResourceCollection < Array
    NotFoundError = Class.new(StandardError)

    def find_by_description(desc)
      # desc is like 'resource_type[name]'
      self.find do |resource|
        type, name = Itamae::Resource.parse_description(desc)
        resource.resource_type == type && resource.resource_name == name
      end.tap do |resource|
        unless resource
          raise NotFoundError, "'#{desc}' resource is not found."
        end
      end
    end

    def subscribing(target)
      self.map do |resource|
        resource.subscribes_resources.map do |action, r, timing|
          if r == target
            [action, resource, timing]
          end
        end.compact
      end.flatten(1)
    end
  end
end
