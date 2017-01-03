# frozen_string_literal: true
# A command that echoes the value for option named 'test-option'
class TestOptionReaderCommand < Cliqr.command
  def execute(context)
    puts context.option('test-option').value
  end
end
