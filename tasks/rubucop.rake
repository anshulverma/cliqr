# encoding: utf-8

begin
  require 'rubocop/rake_task'

  desc 'Run RuboCop on the lib directory'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
    # abort rake on failure
    task.fail_on_error = true
  end
rescue
  # do nothing
end
