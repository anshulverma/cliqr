# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rake/clean'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

FileList['tasks/*.rake'].each(&method(:import))

desc 'run code coverage checker'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
end

desc 'default rake task'
task default: [:clean, :coverage, :rubocop, :verify_measurements, :yardstick_measure]

desc 'run CI tasks'
task :ci do
  ENV['CI'] = 'true'
  Rake::Task['default'].invoke
end

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
