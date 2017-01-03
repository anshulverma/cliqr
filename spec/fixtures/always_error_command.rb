# frozen_string_literal: true
# A command that always throws an error
class AlwaysErrorCommand < Cliqr.command
  def execute(_context)
    raise StandardError, 'I always throw an error'
  end
end
