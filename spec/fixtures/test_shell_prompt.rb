# frozen_string_literal: true
# A custom test command prompt
class TestShellPrompt < Cliqr.shell_prompt
  def initialize
    @count = 0
  end

  def build(_context)
    @count += 1
    "test-prompt [#{@count}] > "
  end
end
