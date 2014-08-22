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
          @current_attributes[:uid] = run_command(["id", "-u", username]).stdout.strip
          @current_attributes[:gid] = run_command(["id", "-g", username]).stdout.strip
          @current_attributes[:home] = run_command("echo ~#{shell_escape(username)}").stdout.strip
        end
      end

      def create_action
        if run_specinfra(:check_user_exists, username)
          if uid && uid.to_s != @current_attributes[:uid]
            run_command(["usermod", "-u", uid, username]) 
            updated!
          end

          if gid && gid.to_s != @current_attributes[:gid]
            run_command(["usermod", "-g", gid, username])
            updated!
          end

          if password && password != current_password
            run_command("echo #{shell_escape("#{username}:#{password}")} | chpasswd -e")
            updated!
          end
        else
          args = ["useradd"]
          args << "-g" << gid if gid
          args << "-d" << home if home
          args << "-p" << password if password
          args << "-r" if system_user
          args << "-u" << uid.to_s if uid
          args << username
          run_command(args)

          updated!
        end
      end

      private
      def exist?
        run_specinfra(:check_user_exists, username)
      end

      def current_password
        run_command("cat /etc/shadow | grep -E ^itamae:").stdout.split(":")[1]
      end
    end
  end
end

