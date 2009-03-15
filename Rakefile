# Rakefile for constantrecord
require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('constantrecord', '0.0.1') do |p|
  p.description = "A tiny ActiveRecord substitute for small, never changing database tables."
  p.url = "http://github.com/ChristophPetschnig/constantrecord"
  p.author = "Christoph Petschnig"
  p.email = "info@purevirtual.de"
  p.ignore_pattern = ["tmp/*", "script/*", "rdoc/*", "pkg/*"]
  p.development_dependencies = []
  p.rdoc_pattern = /^(lib|bin|tasks|ext)|^README.rdoc|^CHANGELOG|^TODO|^MIT-LICENSE|^COPYING$/
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }


task :default => :test

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end


