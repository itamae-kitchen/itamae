source 'https://rubygems.org'

# Specify your gem's dependencies in lightchef.gemspec
gemspec

gemfile_local = File.expand_path('../Gemfile.local', __FILE__)
if File.exist?(gemfile_local)
  load gemfile_local
end

group :test do
  if RUBY_PLATFORM.include?('darwin')
    gem 'growl'
  end
end

