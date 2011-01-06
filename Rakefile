require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

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
    gemspec.files = Dir["{lib}/**/*", "{app}/**/*", "Gemfile", "{config}/**/*", "README.md"]
    gemspec.description = %{
      Grandstand is a simple blog and photo gallery application. It takes a minimal amount of configuration and can
      be built installed as a gem and used within minutes. It's totally cool. Seriously.
    }
    gemspec.email = "flip@x451.com"
    gemspec.homepage = "http://github.com/flipsasser/grandstand"
    gemspec.authors = ["Flip Sasser"]
    gemspec.test_files = Dir["spec/**/*"]
    # TODO: Move less and more to development dependencies
    gemspec.add_dependency 'aws-s3', '>= 0.6.2'
    gemspec.add_dependency 'mustache', '>= 0.11.2'
    gemspec.add_dependency 'paperclip', '>= 2.3.3'
    gemspec.add_dependency 'will_paginate', '>= 2.3'
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end
