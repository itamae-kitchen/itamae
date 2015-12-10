# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "some_itamae_extension"
  spec.version       = "1.0.0"
  spec.authors       = ["itamae"]
  spec.email         = ["itamae"]

  spec.summary       = %q{For Itamae extension auto requiring test}
  spec.homepage      = "http://itamae.kitchen/"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
