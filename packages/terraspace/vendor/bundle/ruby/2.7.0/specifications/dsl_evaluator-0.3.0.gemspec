# -*- encoding: utf-8 -*-
# stub: dsl_evaluator 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dsl_evaluator".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/tongueroo/dsl_evaluator" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tung Nguyen".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-03-14"
  s.email = ["tongueroo@gmail.com".freeze]
  s.homepage = "https://github.com/tongueroo/dsl_evaluator".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.2.26".freeze
  s.summary = "DSL evaluation library. It produces a human-friendly backtrace error".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<memoist>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<zeitwerk>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<memoist>.freeze, [">= 0"])
    s.add_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_dependency(%q<zeitwerk>.freeze, [">= 0"])
  end
end
