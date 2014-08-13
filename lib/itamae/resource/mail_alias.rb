require 'itamae'

module Itamae
  module Resource
    class MailAlias < Base
      define_attribute :action, default: :create
      define_attribute :mail_alias, type: String, default_name: true
      define_attribute :recipient, type: String, required: true

      def create_action
        if ! backend.check_mail_alias_is_aliased_to(mail_alias, recipient)
          backend.add_mail_alias(mail_alias, recipient)
        end
      end
    end
  end
end
