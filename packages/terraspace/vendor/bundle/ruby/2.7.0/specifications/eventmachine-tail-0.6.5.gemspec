# -*- encoding: utf-8 -*-
# stub: eventmachine-tail 0.6.5 ruby lib lib

Gem::Specification.new do |s|
  s.name = "eventmachine-tail".freeze
  s.version = "0.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze, "lib".freeze]
  s.authors = ["Jordan Sissel".freeze]
  s.date = "2016-01-15"
  s.description = "Add file 'tail' implemented with EventMachine. Also includes a 'glob watch' class for watching a directory pattern for new matches, like /var/log/*.log".freeze
  s.email = "jls@semicomplete.com".freeze
  s.executables = ["rtail".freeze, "emtail".freeze]
  s.files = ["bin/emtail".freeze, "bin/rtail".freeze]
  s.homepage = "http://code.google.com/p/semicomplete/wiki/EventMachineTail".freeze
  s.rubygems_version = "3.2.26".freeze
  s.summary = "eventmachine tail - a file tail implementation with glob support".freeze

  s.installed_by_version = "3.2.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<eventmachine>.freeze, [">= 0"])
  else
    s.add_dependency(%q<eventmachine>.freeze, [">= 0"])
  end
end
