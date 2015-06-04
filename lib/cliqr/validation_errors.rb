# encoding: utf-8

require 'set'

module Cliqr
  # A wrapper of validation errors which provides helpful methods for accessing it
  #
  # @api private
  class ValidationErrors
    # List of all error messages
    #
    # @return [Array<String]
    attr_accessor :errors

    # Create a new instance of the validation error wrapper
    def initialize
      @errors = Set.new []
    end

    # Add a new error message
    #
    # @param [String] error_message
    #
    # @return [Array] A collection of all error messages
    def add(error_message)
      @errors.add(error_message)
    end

    # Check if there are error or not
    #
    # @return [Boolean] <tt>false</tt> if there are no errors
    def empty?
      @errors.empty?
    end

    # Convert list of errors to a string representation
    #
    # @return [String] A comma separated list of all errors
    def to_s
      @errors.to_a.join(', ')
    end

    # Merge the list of errors from another
    #
    # @param [Cliqr::Validation::Errors] other Errors that need to be merged
    #
    # @return [Cliqr::Validation::Errors] Updated errors list
    def merge(other)
      @errors = @errors.union(other.errors)
    end

    # Iterate over each error message
    #
    # @param [Function] block The iterating function
    #
    # @return [Set<String>] A set of all error messages
    def each(&block)
      @errors.each(&block)
    end
  end
end
