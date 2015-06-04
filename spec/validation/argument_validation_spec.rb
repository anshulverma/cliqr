# encoding: utf-8

require 'spec_helper'

require 'cliqr/argument_validation/validator'

require 'fixtures/test_command'
require 'fixtures/test_option_reader_command'

describe Cliqr::ArgumentValidation::Validator do
  it 'can validate numerical arguments' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        type :numeric
      end
    end

    result = cli.execute %w(--test-option 123), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
123
    EOS
  end

  it 'does not allow string for numeric option types' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestCommand

      option 'age' do
        type :numeric
      end
    end

    expect do
      cli.execute %w(--age abcd)
    end.to raise_error(Cliqr::Error::IllegalArgumentError,
                       "illegal argument error - only values of type 'numeric' allowed for option 'age'")
  end
end
