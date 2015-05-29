# encoding: utf-8

require 'spec_helper'

require 'cliqr/error'

require 'fixtures/test_command'
require 'fixtures/always_error_command'
require 'fixtures/option_reader_command'
require 'fixtures/test_option_reader_command'

describe Cliqr::CLI::Executor do
  it 'returns code 0 for default command runner' do
    expect(Cliqr.command.new.execute).to eq(0)
  end

  it 'routes base command with no arguments' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestCommand
    end
    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'handles error appropriately' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler AlwaysErrorCommand
    end
    expect { cli.execute [] }.to raise_error(Cliqr::Error::CommandRuntimeException)
  end

  it 'routes a command with option values' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'lets a command get all option values' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler OptionReaderCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my-command

[option] test-option => some-value
    EOS
  end

  it 'lets a command get single option value' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestOptionReaderCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
some-value
    EOS
  end

  it 'handles executor error cause properly' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler AlwaysErrorCommand
    end
    begin
      cli.execute
    rescue Cliqr::Error::CliqrError => e
      expect(e.backtrace[0]).to end_with "cliqr/spec/fixtures/always_error_command.rb:6:in `execute'"
      expect(e.message).to eq "command 'my-command' failed\n\nCause: StandardError - I always throw an error"
    end
  end
end
