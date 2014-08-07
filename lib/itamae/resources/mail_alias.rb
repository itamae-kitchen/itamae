require 'itamae'

module Itamae
  module Resources
    class MailAlias < Base
      define_option :action, default: :create
      define_option :mail_alias, type: String, default_name: true
      define_option :recipient, type: String, required: true

      def create_action
        if ! backend.check_mail_alias_is_aliased_to(mail_alias, recipient)
          backend.add_mail_alias(mail_alias, recipient)
        end
      end
    end
  end
end
