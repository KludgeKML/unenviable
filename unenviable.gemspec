# encoding: utf-8
Gem::Specification.new do |s|
  s.name        = 'unenviable'
  s.version     = '0.3.0'
  s.date        = '2014-11-19'
  s.summary     = 'Unenviable'
  s.description = 'Makes ENV vars easier to keep track of in distributed development'
  s.authors     = ['K M Lawrence']
  s.email       = 'keith@kludge.co.uk'
  s.executables = ['unenviable']
  s.files       = ['lib/unenviable.rb', 'lib/unenviable/env_wrapper.rb', 'bin/unenviable']
  s.homepage    = 'http://rubygems.org/gems/unenviable'
  s.license     = 'MIT'

  s.add_runtime_dependency 'dotenv', '~> 0.11'
end
