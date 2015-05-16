# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'levenshtein/version'

Gem::Specification.new do |spec|
  spec.name          = "levenshtein-jruby"
  spec.version       = Levenshtein::VERSION
  spec.platform = 'java'

  spec.authors       = ["David Butler"]
  spec.email         = ["dwbutler@ucla.edu"]
  spec.description   = %q{Calculate the Levenshtein distance between two strings in JRuby}
  spec.summary       = %q{Levenshtein gem that runs in JRuby}
  spec.homepage      = "https://github.com/dwbutler/levenshtein-jruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
