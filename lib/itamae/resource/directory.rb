require 'itamae'

module Itamae
  module Resource
    class Directory < Base
      define_attribute :action, default: :create
      define_attribute :path, type: String, default_name: true
      define_attribute :mode, type: String
      define_attribute :owner, type: String
      define_attribute :group, type: String

      def create_action
        if ! backend.check_file_is_directory(path)
          backend.create_file_as_directory(path)
        end
        if attributes[:mode]
          backend.change_file_mode(path, attributes[:mode])
        end
        if attributes[:owner] || attributes[:group]
          backend.change_file_owner(path, attributes[:owner], attributes[:group])
        end
      end
    end
  end
end

