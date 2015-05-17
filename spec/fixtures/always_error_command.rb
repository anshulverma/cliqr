# encoding: utf-8

# A command that always throws an error
class AlwaysErrorCommand < Cliqr.command
  def execute(_context)
    fail StandardError, 'I always throw an error'
  end
end
