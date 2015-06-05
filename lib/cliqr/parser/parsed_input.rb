# encoding: utf-8
module Cliqr
  module Parser
    # A wrapper to keep the parsed input arguments
    #
    # @api private
    class ParsedInput
      # Command name
      #
      # @return [String]
      attr_accessor :command

      # Hash of options parsed from the command line
      #
      # @return [Hash]
      attr_accessor :options

      # List of arguments from the command line
      #
      # @return [Array<String>]
      attr_accessor :arguments

      # Initialize a new parsed input
      def initialize(parsed_arguments)
        @command = parsed_arguments[:command]

        @options = Hash[parsed_arguments[:options].collect \
            { |option| [option[:name], option[:value]] }]\
            if parsed_arguments.key?(:options)

        @arguments = parsed_arguments[:arguments]
      end

      # Get a value of an option
      #
      # @param [String] name Name of the option
      #
      # @return [String]
      def option(name)
        @options[name]
      end

      # Test equality with another object
      #
      # @return [Boolean] <tt>true</tt> if this object is equal to <tt>other</tt>
      def eql?(other)
        self.class.equal?(other.class) &&
          @command == other.command &&
          @options == other.options
      end

      # Test equality with another object
      #
      # @return [Boolean] <tt>true</tt> if this object is equal to <tt>other</tt>
      def ==(other)
        eql?(other)
      end
    end
  end
end
