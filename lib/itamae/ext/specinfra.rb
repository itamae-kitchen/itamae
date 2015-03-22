# TODO: Send patches to Specinfra

Specinfra::Command::Base::User.class_eval do
  class << self
    def update_home_directory(user, directory)
      # -m: Move the content of the user's home directory to the new location.
      "usermod -m -d #{escape(directory)} #{escape(user)}"
    end
  end
end
