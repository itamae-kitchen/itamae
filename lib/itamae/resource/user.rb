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

      def create_action
        if run_specinfra(:check_user_exists, username)
          Logger.warn "User already exists. Currently, user resources do not support to modify attributes."
        else
          args = ["useradd"]
          args << "-g" << gid if gid
          args << "-d" << home if home
          args << "-p" << password if password
          args << "-r" if system_user
          args << "-u" << uid.to_s if uid
          args << username
          run_command(args)
        end
      end
    end
  end
end

