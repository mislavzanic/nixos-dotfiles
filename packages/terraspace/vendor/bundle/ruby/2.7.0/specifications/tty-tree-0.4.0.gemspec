# -*- encoding: utf-8 -*-
# stub: tty-tree 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "tty-tree".freeze
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/piotrmurach/tty-tree/issues", "changelog_uri" => "https://github.com/piotrmurach/tty-tree/blob/master/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/tty-tree", "homepage_uri" => "https://piotrmurach.github.io/tty", "source_code_uri" => "https://github.com/piotrmurach/tty-tree" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Piotr Murach".freeze]
  s.date = "2020-01-16"
  s.description = "Print directory or structured data in a tree like format.".freeze
  s.email = ["piotr@piotrmurach.com".freeze]
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze]
  s.homepage = "https://piotrmurach.github.io/tty".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.2.26".freeze
  s.summary = "Print directory or structured data in a tree like format.".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.14.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  else
    s.add_dependency(%q<bundler>.freeze, [">= 1.14.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
  end
end
