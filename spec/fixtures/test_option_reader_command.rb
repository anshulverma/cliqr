# encoding: utf-8

# A command that echoes the value for option named 'test-option'
class TestOptionReaderCommand < Cliqr.command
  def execute(context)
    puts context.option('test-option').value
  end
end
