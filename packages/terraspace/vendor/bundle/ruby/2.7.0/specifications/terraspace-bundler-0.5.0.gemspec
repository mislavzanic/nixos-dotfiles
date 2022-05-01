# -*- encoding: utf-8 -*-
# stub: terraspace-bundler 0.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "terraspace-bundler".freeze
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tung Nguyen".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-01-15"
  s.email = ["tung@boltops.com".freeze]
  s.executables = ["terraspace-bundler".freeze]
  s.files = ["exe/terraspace-bundler".freeze]
  s.homepage = "https://github.com/boltops-tools/terraspace-bundler".freeze
  s.licenses = ["Apache2.0".freeze]
  s.rubygems_version = "3.2.26".freeze
  s.summary = "Bundles terraform modules".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<aws-sdk-s3>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<dsl_evaluator>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<memoist>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rubyzip>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<thor>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<zeitwerk>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<aws-sdk-s3>.freeze, [">= 0"])
    s.add_dependency(%q<dsl_evaluator>.freeze, [">= 0"])
    s.add_dependency(%q<memoist>.freeze, [">= 0"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
    s.add_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_dependency(%q<rubyzip>.freeze, [">= 0"])
    s.add_dependency(%q<thor>.freeze, [">= 0"])
    s.add_dependency(%q<zeitwerk>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
