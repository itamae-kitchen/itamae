require 'itamae'

module Itamae
  module Resource
    class User < Base
      define_attribute :action, default: :create
      define_attribute :username, type: String, default_name: true
      define_attribute :gid, type: [Integer, String]
      define_attribute :home, type: String
      define_attribute :password, type: String
      define_attribute :system_user, type: [TrueClass, FalseClass]
      define_attribute :uid, type: Integer

      def pre_action
        case @current_action
        when :create
          attributes.exist = true
        end
      end

      def set_current_attributes
        current.exist = exist?

        if current.exist
          current.uid = run_specinfra(:get_user_uid, attributes.username).stdout.strip.to_i
          current.gid = run_specinfra(:get_user_gid, attributes.username).stdout.strip.to_i
          current.home = run_specinfra(:get_user_home_directory, attributes.username).stdout.strip
          current.password = current_password
        end
      end

      def action_create(options)
        if run_specinfra(:check_user_exists, attributes.username)
          if attributes.uid && attributes.uid != current.uid
            run_specinfra(:update_user_uid, attributes.username, attributes.uid)
            updated!
          end

          if attributes.gid && attributes.gid != current.gid
            run_specinfra(:update_user_gid, attributes.username, attributes.gid)
            updated!
          end

          if attributes.password && attributes.password != current.password
            run_specinfra(:update_user_encrypted_password, attributes.username, attributes.password)
            updated!
          end

          if attributes.home && attributes.home != current.home
            run_specinfra(:update_user_home_directory, attributes.username, attributes.home)
            updated!
          end
        else
          options = {
            gid:            attributes.gid,
            home_directory: attributes.home,
            password:       attributes.password,
            system_user:    attributes.system_user,
            uid:            attributes.uid,
          }

          run_specinfra(:add_user, attributes.username, options)

          updated!
        end
      end

      private
      def exist?
        run_specinfra(:check_user_exists, attributes.username)
      end

      def current_password
        result = run_specinfra(:get_user_encrypted_password, attributes.username)
        if result.success?
          result.stdout.strip
        else
          nil
        end
      end
    end
  end
end
