# frozen_string_literal: true
# Test command for the router_spec
class TestCommand < Cliqr.command
  def execute(_context)
    puts 'test command executed'
  end
end
