# -*- encoding: utf-8 -*-
# stub: cli-format 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cli-format".freeze
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/tongueroo/cli-format" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tung Nguyen".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-02-15"
  s.email = ["tongueroo@gmail.com".freeze]
  s.homepage = "https://github.com/tongueroo/cli-format".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.26".freeze
  s.summary = "Format cli output in different ways: tab, table, csv, json, etc".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<text-table>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<zeitwerk>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<text-table>.freeze, [">= 0"])
    s.add_dependency(%q<zeitwerk>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
  end
end
