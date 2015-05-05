require 'cliqr/dsl'

module Cliqr
  # Defines dsl methods for building a command line interface
  class CLI
    extend Cliqr::DSL

    # base name of the top level command
    attr_writer :basename

    # Get usage information of this command line interface instance
    #
    # @return [String]
    #
    # @api public
    def usage
      <<-EOS
        USAGE: #{@basename}
      EOS
    end

    # dsl methods
    dsl do
      def basename(basename)
        set_basename basename
      end
    end
  end
end
