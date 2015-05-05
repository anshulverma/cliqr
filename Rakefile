# encoding: utf-8

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task default: [:spec]

desc 'Run all specs on CI'
task ci: [:spec]

desc 'Load gem inside irb console'
task :console do
  require 'irb'
  require 'irb/completion'
  require File.join(__FILE__, '../lib/cliqr')
  ARGV.clear
  IRB.start
end
