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

  it 'can validate boolean option arguments' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        type :boolean
      end
    end

    result = cli.execute %w(--test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
true
    EOS
  end

  it 'can validate boolean option argumentswith short name' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        short 't'
        type :boolean
      end
    end

    result = cli.execute %w(-t), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
true
    EOS
  end

  it 'can validate boolean option arguments for false' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        type :boolean
      end
    end

    result = cli.execute %w(--no-test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
false
    EOS
  end

  it 'does not allow string for boolean option types' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestCommand

      option 'opt' do
        type :boolean
      end
    end

    expect do
      cli.execute %w(--opt qwe)
    end.to raise_error(Cliqr::Error::InvalidArgumentError,
                       "invalid command argument \"qwe\"")
  end

  it 'allows numeric options to be optional' do
    cli = Cliqr.interface do
      basename 'my-command'
      description 'this is an awesome command...try it out'
      handler TestCommand

      option 'count' do
        type :numeric
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test command executed
    EOS
  end

  it 'allows boolean options to be optional' do
    cli = Cliqr.interface do
      basename 'my-command'
      description 'this is an awesome command...try it out'
      handler TestCommand

      option 'single' do
        type :boolean
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test command executed
    EOS
  end
end
