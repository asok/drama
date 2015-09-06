# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'drama/version'

Gem::Specification.new do |spec|
  spec.name          = "drama"
  spec.version       = Drama::VERSION
  spec.authors       = ["asok"]
  spec.email         = ["adam.sokolnicki@gmail.com"]

  spec.summary       = "Service layer for Rails"
  spec.description   = "Create Acts which are service like objects that create a fourth layer between controllers and models in Rails applications."
  spec.homepage      = "https://github.com/asok/drama"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "actionpack"
  spec.add_dependency "activesupport"
end
