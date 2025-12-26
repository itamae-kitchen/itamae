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

# FIXME: Delete the following after https://github.com/fakefs/fakefs/pull/494 is merged and released
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("4.0.0.preview2")
  gem "english"
  gem "fileutils"
  gem "find"
  gem "irb"
  gem "stringio"
end
