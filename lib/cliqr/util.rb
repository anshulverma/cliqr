# encoding: utf-8

module Cliqr
  # Utility methods
  #
  # @api private
  class Util
    # Ensure that a variable is a instance object not a class type
    #
    # @return [Object]
    def self.ensure_instance(obj)
      return obj.new if obj.class == Class
      obj
    end
  end
end
