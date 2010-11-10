require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the grandstand plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the grandstand plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Grandstand'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.markdown')
  # rdoc.rdoc_files.include('app/**/*.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require "jeweler"
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "grandstand"
    gemspec.summary = "A blog / gallery gem for Rails 3 that's dead-simple to configure, override, and rebuild"
    # gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", "{public}/**/*", "{rails}/**/*", "README"]
    # other fields that would normally go in your gemspec
    # like authors, email and has_rdoc can also be included here
    gemspec.description = %{
      Grandstand is a simple blog and photo gallery application. It takes a minimal amount of configuration and can
      be built installed as a gem and used within minutes. It's totally cool. Seriously.
    }
    gemspec.email = "flip@x451.com"
    gemspec.homepage = "http://github.com/flipsasser/grandstand"
    gemspec.authors = ["Flip Sasser"]
    gemspec.test_files = []
    # TODO: Move less and more to development dependencies
    gemspec.add_development_dependency 'less', '>= 1.2.21'
    gemspec.add_development_dependency 'more', '>= 0.1.1'
    gemspec.add_dependency 'aws-s3', '>= 0.6.2'
    gemspec.add_dependency 'mustache', '>= 0.11.2'
    gemspec.add_dependency 'paperclip', '>= 2.3.3'
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end
