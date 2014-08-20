# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae"
  spec.version       = Itamae::VERSION
  spec.authors       = ["Ryota Arai"]
  spec.email         = ["ryota.arai@gmail.com"]
  spec.summary       = %q{Simple Configuration Management Tool}
  spec.homepage      = "https://github.com/ryotarai/itamae"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "specinfra", "2.0.0.beta37"
  spec.add_runtime_dependency "hashie"
  spec.add_runtime_dependency "ansi"

  # TODO: move to specinfra
  spec.add_runtime_dependency "net-scp"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "serverspec", "2.0.0.beta20"
  spec.add_development_dependency "pry-byebug"
end
