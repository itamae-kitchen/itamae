source 'https://rubygems.org'

# Specify your gem's dependencies in itamae.gemspec
gemspec

path = Pathname.new("Gemfile.local")
eval(path.read) if path.exist?

group :test do
  if RUBY_PLATFORM.include?('darwin')
    gem 'growl'
  end
end

gem 'excon', git: 'https://github.com/unasuke/excon.git', branch: 'frozen_string_literal'
