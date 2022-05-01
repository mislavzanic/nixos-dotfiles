# -*- encoding: utf-8 -*-
# stub: rhcl 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rhcl".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Genki Sugawara".freeze]
  s.date = "2014-09-21"
  s.description = "Pure Ruby HCL parser".freeze
  s.email = ["sgwr_dts@yahoo.co.jp".freeze]
  s.homepage = "https://github.com/winebarrel/rhcl".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.26".freeze
  s.summary = "Pure Ruby HCL parser".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<deep_merge>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<racc>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 3.0.0"])
  else
    s.add_dependency(%q<deep_merge>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<racc>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.0.0"])
  end
end
