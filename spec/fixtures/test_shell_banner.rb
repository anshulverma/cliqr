# frozen_string_literal: true
# A custom test command banner
class TestShellBanner < Cliqr.shell_banner
  def build(context)
    "welcome to the command #{context.command}"
  end
end
