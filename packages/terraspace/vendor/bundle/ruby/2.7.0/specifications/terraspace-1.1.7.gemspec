# -*- encoding: utf-8 -*-
# stub: terraspace 1.1.7 ruby lib

Gem::Specification.new do |s|
  s.name = "terraspace".freeze
  s.version = "1.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/boltops-tools/terraspace/blob/master/CHANGELOG.md", "homepage_uri" => "https://terraspace.cloud", "source_code_uri" => "https://github.com/boltops-tools/terraspace" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tung Nguyen".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-02-22"
  s.email = ["tung@boltops.com".freeze]
  s.executables = ["terraspace".freeze]
  s.files = ["exe/terraspace".freeze]
  s.homepage = "https://terraspace.cloud".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.2.26".freeze
  s.summary = "Terraspace: The Terraspace Framework".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<cli-format>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<deep_merge>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<dotenv>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<dsl_evaluator>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<eventmachine-tail>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<graph>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<hcl_parser>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<memoist>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<render_me_pretty>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rexml>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<terraspace-bundler>.freeze, [">= 0.5.0"])
    s.add_runtime_dependency(%q<thor>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<tty-tree>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<zeitwerk>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rspec-terraspace>.freeze, [">= 0.3.1"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_development_dependency(%q<cli_markdown>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<cli-format>.freeze, [">= 0"])
    s.add_dependency(%q<deep_merge>.freeze, [">= 0"])
    s.add_dependency(%q<dotenv>.freeze, [">= 0"])
    s.add_dependency(%q<dsl_evaluator>.freeze, [">= 0"])
    s.add_dependency(%q<eventmachine-tail>.freeze, [">= 0"])
    s.add_dependency(%q<graph>.freeze, [">= 0"])
    s.add_dependency(%q<hcl_parser>.freeze, [">= 0"])
    s.add_dependency(%q<memoist>.freeze, [">= 0"])
    s.add_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_dependency(%q<render_me_pretty>.freeze, [">= 0"])
    s.add_dependency(%q<rexml>.freeze, [">= 0"])
    s.add_dependency(%q<terraspace-bundler>.freeze, [">= 0.5.0"])
    s.add_dependency(%q<thor>.freeze, [">= 0"])
    s.add_dependency(%q<tty-tree>.freeze, [">= 0"])
    s.add_dependency(%q<zeitwerk>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-terraspace>.freeze, [">= 0.3.1"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<cli_markdown>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
