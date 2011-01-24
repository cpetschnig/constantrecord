require 'rubygems'
require 'rake'

version = File.exist?('VERSION') ? File.read('VERSION') : ""

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "constantrecord"
    gem.summary = %Q{A tiny ActiveRecord substitute for small, never changing database tables.}
    gem.description = %Q{A tiny ActiveRecord substitute for small, never changing database tables.}
    gem.email = "info@purevirtual.de"
    gem.homepage = "http://github.com/cpetschnig/constantrecord"
    gem.authors = ["Christoph Petschnig"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.version = version
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "constantrecord #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
