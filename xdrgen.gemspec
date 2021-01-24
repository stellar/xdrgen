# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xdrgen/version'

Gem::Specification.new do |spec|
  spec.name          = "xdrgen"
  spec.version       = Xdrgen::VERSION
  spec.authors       = ["Scott Fleckenstein"]
  spec.email         = ["scott@stellar.org"]
  spec.summary       = %q{An XDR code generator}
  spec.homepage      = "http://github.com/stellar/xdrgen"
  spec.license       = "ISC"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency "treetop", "~> 1.5.3"
  spec.add_dependency "activesupport", "~> 6"
  spec.add_dependency "slop", "~> 3.4"
  spec.add_dependency "memoist", "~> 0.11.0"

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
end
