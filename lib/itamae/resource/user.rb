require 'itamae'

module Itamae
  module Resource
    class User < Base
      define_attribute :action, default: :create
      define_attribute :username, type: String, default_name: true
      define_attribute :gid, type: String
      define_attribute :home, type: String
      define_attribute :password, type: String
      define_attribute :system_user, type: [TrueClass, FalseClass]
      define_attribute :uid, type: [String, Integer]

      def set_current_attributes
        @current_attributes[:exist?] = exist?

        if @current_attributes[:exist?]
          @current_attributes[:uid] = run_specinfra(:get_user_uid, username).stdout.strip
          @current_attributes[:gid] = run_specinfra(:get_user_gid, username).stdout.strip
          @current_attributes[:home] = run_specinfra(:get_user_home_directory, username).stdout.strip
          @current_attributes[:password] = current_password
        end
      end

      def create_action(options)
        if run_specinfra(:check_user_exists, username)
          if uid && uid.to_s != @current_attributes[:uid]
            run_specinfra(:update_user_uid, username, uid)
            updated!
          end

          if gid && gid.to_s != @current_attributes[:gid]
            run_specinfra(:update_user_gid, username, gid)
            updated!
          end

          if password && password != current_password
            run_specinfra(:update_user_encrypted_password, username, password)
            updated!
          end
        else
          options = {
            gid:            gid,
            home_directory: home,
            password:       password,
            system_user:    system_user,
            uid:            uid,
          }

          run_specinfra(:add_user, username, options)

          updated!
        end
      end

      private
      def exist?
        run_specinfra(:check_user_exists, username)
      end

      def current_password
        result = run_specinfra(:get_user_encrypted_password, username)
        if result.success?
          result.stdout.strip
        else
          nil
        end
      end
    end
  end
end

