# encoding: utf-8

require 'rake'
require 'rake/testtask'
 
desc 'Default: run unit tests.'
task :default => :test
 
desc 'Run unit tests.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name     = 'liquidizer'
    gemspec.summary  = 'Support for Ruby on Rails views powered by Liquid and loaded from database'
    gemspec.description = <<END
WIth this gem, you can render your Ruby on Rails views with liquid templates that are loaded from database. This way, the look and feel of your site can be safely configured by it's users.
END

    gemspec.email    = 'adam.ciganek@gmail.com'
    gemspec.homepage = 'http://github.com/madadam/liquidizer'
    gemspec.authors  = ['Adam Cigánek']

    gemspec.add_dependency 'liquid', '>= 2.0.0'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
