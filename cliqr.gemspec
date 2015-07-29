# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cliqr/version'

Gem::Specification.new do |spec|
  spec.name          = 'cliqr'
  spec.version       = Cliqr::VERSION
  spec.authors       = ['Anshul Verma']
  spec.email         = ['ansverma@adobe.com']
  spec.summary       = %q{A framework and DSL for defining CLI interface}
  spec.homepage      = 'https://github.com/anshulverma/cliqr'
  spec.description   = <<-EOS
                          Allows you to easily define the interface for a CLI app
                          using an easy to use DSL.

                          Includes a lightweight framework for a CLI app.
                          Features: command routing, error handling, usage generation...more to come
                       EOS
  spec.license       = 'MIT'

  spec.files         = Dir['Rakefile', '{lib,spec,tasks,examples}/**/*', 'README*', 'LICENSE*', 'CHANGELOG*']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version     = '>= 1.9.3'
  spec.required_rubygems_version = '>= 1.3.6'

  # runtime dependencies
  {
      :sawaal => '~> 1.1.0'
  }.each { |dependency, version| spec.add_dependency dependency.to_s, version }

  # development dependencies
  {
      :bundler => '~> 1.6'
  }.each { |dependency, version| spec.add_development_dependency dependency.to_s, version }
end
