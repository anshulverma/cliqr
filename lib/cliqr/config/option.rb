# encoding: utf-8

require 'cliqr/config/named'
require 'cliqr/command/argument_operator'

module Cliqr
  module Config
    # Config attributes for a command's option
    #
    # @api private
    class Option < Cliqr::Config::Named
      # Optional short name for the option
      #
      # @return [String]
      attr_accessor :short
      validates :short,
                non_empty_nil_ok_format: /^[a-z0-9A-Z]$/

      # Optional field that restricts values of this option to a certain type
      #
      # @return [Symbol] Type of the option
      attr_accessor :type
      validates :type,
                inclusion: [:any, Config::NUMERIC_ARGUMENT_TYPE, Config::BOOLEAN_ARGUMENT_TYPE]

      # Operation to be applied to the option value after validation
      #
      # @return [Class<Cliqr::Command::ArgumentOperator>]
      attr_accessor :operator
      validates :operator,
                one_of: [
                  { extend: Cliqr::Command::ArgumentOperator },
                  { type_of: Proc }
                ]

      # Enable or disable multiple values for this option
      #
      # @return [Boolean]
      attr_accessor :multi_valued
      validates :multi_valued,
                inclusion: [true, false]

      # Default value for this option
      #
      # @return [Object]
      attr_accessor :default

      # Initialize a new config instance for an option with UNSET attribute values
      def initialize
        super

        @short = UNSET
        @type = UNSET
        @operator = UNSET
        @default = UNSET
        @multi_valued = UNSET
      end

      # Finalize option's config by adding default values for unset values
      #
      # @return [Cliqr::Config::Option]
      def finalize
        super

        @short = Config.get_if_unset(@short, nil)
        @type = Config.get_if_unset(@type, ANY_ARGUMENT_TYPE)
        @operator = Util.ensure_instance(
          Config.get_if_unset(@operator, Cliqr::Command::ArgumentOperator.for_type(@type)))
        @default = Config.get_if_unset(@default, ARGUMENT_DEFAULTS[@type])
        @multi_valued = Config.get_if_unset(@multi_valued, false)

        self
      end

      # Check if a option's short name is defined
      #
      # @return [Boolean] <tt>true</tt> if options' short name is not null neither empty
      def short?
        !(@short.nil? || @short.empty?)
      end

      # Check if a option's type is defined
      #
      # @return [Boolean] <tt>true</tt> if options' type is not nil and not equal to <tt>:any</tt>
      def type?
        !@type.nil? && @type != :any
      end

      # Check if a option is of boolean type
      #
      # @return [Boolean] <tt>true</tt> is the option is of type <tt>:boolean</tt>
      def boolean?
        @type == :boolean
      end

      # Check if a default value setting is defined
      #
      # @return [Boolean]
      def default?
        !@default.nil?
      end

      # Check if this option supports multiple values
      def multi_valued?
        @multi_valued
      end
    end
  end
end
