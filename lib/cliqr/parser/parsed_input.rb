# frozen_string_literal: true
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
        @options = parsed_arguments[:options]
        @arguments = parsed_arguments[:arguments]
      end

      # Get a value of an option
      #
      # @param [String] name Name of the option
      #
      # @return [String]
      def option(name)
        @options[name.to_s]
      end

      # Remove a option
      #
      # @return [Object] Option's original value
      def remove_option(name)
        @options.delete(name.to_s)
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

      # Get name of default action if present as option
      #
      # @return [Symbol] Name of the default action or <tt>nil</tt> if not present
      def default_action(action_config)
        if option('help') && action_config.help?
          return :help
        elsif option('version') && action_config.version?
          return :version
        end
        nil
      end
    end
  end
end
