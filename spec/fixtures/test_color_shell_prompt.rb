# frozen_string_literal: true
# A custom colored test command prompt
class TestColorShellPrompt < Cliqr.shell_prompt
  def initialize
    @count = 0
  end

  def build(_context)
    @count += 1
    red("test-prompt [#{@count}] > ")
  end
end
