# frozen_string_literal: true
# A command that echoes the value for option named 'test-option'
class ArgumentReaderCommand < Cliqr.command
  def execute(context)
    puts context.arguments
  end
end
