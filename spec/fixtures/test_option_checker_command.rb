# encoding: utf-8

# A command that echoes the value for option named 'test-option'
class TestOptionCheckerCommand < Cliqr.command
  def execute(context)
    puts 'test-option is defined' if context.option?('test-option')
  end
end
