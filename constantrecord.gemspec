# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{constantrecord}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph Petschnig"]
  s.date = %q{2009-02-20}
  s.description = %q{A tiny ActiveRecord substitute for small, never changing database tables.}
  s.email = %q{}
  s.extra_rdoc_files = ["lib/constantrecord.rb", "README.rdoc"]
  s.files = ["lib/constantrecord.rb", "Rakefile", "README.rdoc", "Manifest", "constantrecord.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ChristophPetschnig/constantrecord}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Constantrecord", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{constantrecord}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A tiny ActiveRecord substitute for small, never changing database tables.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
