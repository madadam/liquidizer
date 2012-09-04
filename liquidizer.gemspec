# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'liquidizer/version'
 
Gem::Specification.new do |s|
  s.name        = 'liquidizer'
  s.version     = Liquidizer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Adam Cigánek"]
  s.email       = 'adam.ciganek@gmail.com'
  s.homepage    = 'http://github.com/madadam/liquidizer'
  s.summary     = 'Support for Ruby on Rails views powered by Liquid and loaded from database'
  s.description = <<END
WIth this gem, you can render your Ruby on Rails views with liquid templates that are loaded from database. This way, the look and feel of your site can be safely configured by it's users.
END

  s.required_rubygems_version = ">= 1.3.7"

  s.add_dependency 'actionpack'
  s.add_dependency 'activerecord'
  s.add_dependency 'liquid',       '>= 2.0.0'
 
  s.files = Dir.glob('{lib,bin}/**/*')
  s.files << 'README.rdoc'
  s.files << 'Rakefile'
end
