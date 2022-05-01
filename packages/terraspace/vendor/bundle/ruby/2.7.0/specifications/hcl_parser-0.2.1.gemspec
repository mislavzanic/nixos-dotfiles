# -*- encoding: utf-8 -*-
# stub: hcl_parser 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hcl_parser".freeze
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/boltops-tools/hcl_parser" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tung Nguyen".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-11-28"
  s.email = ["tongueroo@gmail.com".freeze]
  s.homepage = "https://github.com/boltops-tools/hcl_parser".freeze
  s.licenses = ["Apache2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.2.26".freeze
  s.summary = "HCL Variables Parser".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rhcl>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rhcl>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
