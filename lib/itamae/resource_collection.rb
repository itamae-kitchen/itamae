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
  end
end
