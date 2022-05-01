# -*- encoding: utf-8 -*-
# stub: render_me_pretty 0.8.4 ruby lib

Gem::Specification.new do |s|
  s.name = "render_me_pretty".freeze
  s.version = "0.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tung Nguyen".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-12-28"
  s.email = ["tongueroo@gmail.com".freeze]
  s.homepage = "https://github.com/tongueroo/render_me_pretty".freeze
  s.rubygems_version = "3.2.26".freeze
  s.summary = "Render ERB template and provide more useful message pointing out the line with the error in the view".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<tilt>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_dependency(%q<tilt>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
