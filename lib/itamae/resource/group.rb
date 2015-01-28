require 'itamae'

module Itamae
  module Resource
    class Group < Base
      define_attribute :action, default: :create
      define_attribute :groupname, type: String, default_name: true
      define_attribute :gid, type: Integer

      def set_current_attributes
        current.exist = exist?

        if current.exist
          current.gid = run_specinfra(:get_group_gid, attributes.groupname).stdout.strip.to_i
        end
      end

      def action_create(options)
        if run_specinfra(:check_group_exists, attributes.groupname)
          if attributes.gid && attributes.gid != current.gid
            run_specinfra(:update_group_gid, attributes.groupname, attributes.gid)
            updated!
          end
        else
          options = {
            gid: attributes.gid,
          }

          run_specinfra(:add_group, attributes.groupname, options)

          updated!
        end
      end

      private
      def exist?
        run_specinfra(:check_group_exists, attributes.groupname)
      end
    end
  end
end

