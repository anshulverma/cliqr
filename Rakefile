# encoding: utf-8

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rake/clean'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

FileList['tasks/*.rake'].each(&method(:import))

desc 'default rake task'
task default: [:clean, :spec, :rubocop, :verify_measurements, :yardstick_measure]

desc 'run CI tasks'
task ci: [:default]

desc 'Load gem inside irb console'
task :console do
  require 'irb'
  require 'irb/completion'
  require File.join(__FILE__, '../lib/cliqr')
  ARGV.clear
  IRB.start
end

# temporary files for cleanup
CLEAN.include('coverage')
