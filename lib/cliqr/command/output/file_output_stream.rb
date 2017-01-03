# frozen_string_literal: true
module Cliqr
  module Command
    module Output
      # Write output to a file
      #
      # @api private
      class FileOutputStream
        # Write to a file and flush the stream
        #
        # @return [Nothing]
        def write(message)
          puts message
          $stdout.flush
        end
      end
    end
  end
end
