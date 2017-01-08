# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polymorph/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-polymorph"
  spec.version       = Polymorph::VERSION
  spec.authors       = ["James Kiesel"]
  spec.email         = ["james.kiesel@gmail.com"]

  spec.summary       = "Allows polymorphic loading of has_many through objects"
  spec.homepage      = "https://www.github.com/gdpelican/activerecord-polymorph"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", "~> 4.1"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
