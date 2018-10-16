# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae"
  spec.version       = Itamae::VERSION
  spec.authors       = ["Ryota Arai", "Yusuke Nakamura", "sue445"]
  spec.email         = ["ryota.arai@gmail.com", "yusuke1994525@gmail.com", "sue445@sue445.net"]
  spec.summary       = %q{Simple Configuration Management Tool}
  spec.homepage      = "https://itamae.kitchen/"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/itamae-kitchen/itamae"
    spec.metadata["changelog_uri"] = "https://github.com/itamae-kitchen/itamae/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "specinfra", [">= 2.64.0", "< 3.0.0"]
  spec.add_runtime_dependency "hashie"
  spec.add_runtime_dependency "ansi"
  spec.add_runtime_dependency "schash", "~> 0.1.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "serverspec", "~> 2.1"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "docker-api", "~> 1.20"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "fluent-logger"
end
