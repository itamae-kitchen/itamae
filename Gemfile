source 'https://rubygems.org'

# Specify your gem's dependencies in itamae.gemspec
gemspec

gem 'vagrant', github: 'mitchellh/vagrant'
gem 'vagrant-digitalocean'

path = Pathname.new("Gemfile.local")
eval(path.read) if path.exist?

group :test do
  if RUBY_PLATFORM.include?('darwin')
    gem 'growl'
  end
end

group :itamae_extensions do
  gem "some_itamae_extension", path: File.expand_path("../spec/some_itamae_extension", __FILE__)
end
