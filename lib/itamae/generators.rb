require_relative "generators/cookbook"
require_relative "generators/project"
require_relative "generators/role"

module Itamae
  module Generators
    def self.find(target)
      case target
      when 'cookbook'
        Cookbook
      when 'project'
        Project
      when 'role'
        Role
      else
        raise "Unexpected target: #{target}"
      end
    end
  end
end
