# encoding: utf-8

require 'spec_helper'

require 'executor/fixtures/test_command'
require 'executor/fixtures/always_error_command'

describe Cliqr::CLI::Router do
  it 'routes base command with no arguments' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestCommand
    end
    result = cli.execute output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'handles error appropriately' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler AlwaysErrorCommand
    end
    expect { cli.execute }.to raise_error(Cliqr::Error::CommandRuntimeException)
  end
end
