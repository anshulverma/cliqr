# frozen_string_literal: true
# A command that echoes the value for option named 'test-option'
class TestOptionTypeCheckerCommand < Cliqr.command
  def execute(context)
    puts "test-option is of type #{context.option('test-option').value.class}"
  end
end
