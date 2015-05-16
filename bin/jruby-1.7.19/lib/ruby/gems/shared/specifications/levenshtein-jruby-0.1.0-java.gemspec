# -*- encoding: utf-8 -*-
# stub: levenshtein-jruby 0.1.0 java lib

Gem::Specification.new do |s|
  s.name = "levenshtein-jruby"
  s.version = "0.1.0"
  s.platform = "java"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["David Butler"]
  s.date = "2013-11-19"
  s.description = "Calculate the Levenshtein distance between two strings in JRuby"
  s.email = ["dwbutler@ucla.edu"]
  s.homepage = "https://github.com/dwbutler/levenshtein-jruby"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5"
  s.summary = "Levenshtein gem that runs in JRuby"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
