# encoding: utf-8

module Cliqr
  module Error
    # Raised when the config parameter is nil
    class ConfigNotFound < StandardError; end

    # Raised when basename is not defined
    class BasenameNotDefined < StandardError; end
  end
end
