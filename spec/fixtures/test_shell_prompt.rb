# encoding: utf-8

# A command that echoes the value for option named 'test-option'
class TestShellPrompt < Cliqr.shell_prompt
  def initialize
    @count = 0
  end

  def prompt(_context)
    @count += 1
    "test-prompt [#{@count}] > "
  end
end
