# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virus_total'

Gem::Specification.new do |spec|
  spec.name          = "virus_total"
  spec.version       = VirusTotal::VERSION
  spec.authors       = ["Rubycop"]
  spec.email         = ["scott.lo@exodus.io"]
  spec.summary       = %q{gem for VirusTotal API version 2.0.}
  spec.description   = %q{gem for VirusTotal API version 2.0.}
  spec.homepage      = "https://github.com/rubycop/virus_total"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.4.18"
  spec.add_development_dependency "rake",    "~> 13.0.6"
  spec.add_development_dependency "rspec",   "~> 3.12"

  spec.add_dependency "rest-client", "~> 2.0"
end