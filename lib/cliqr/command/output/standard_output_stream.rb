# encoding: utf-8

module Cliqr
  module Command
    # Control how output is written out to the stream
    #
    # @api private
    module Output
      # Standard output stream writer
      class StandardOutputStream
        # Write a message directly to the output stream
        #
        # @return [Nothing]
        def write(message)
          puts message
        end
      end
    end
  end
end
