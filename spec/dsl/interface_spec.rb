# encoding: utf-8

require 'spec_helper'

describe Cliqr do
  it 'builds a base command with name' do
    cli = Cliqr.interface do
      basename 'my-command'
      description 'a command used to test cliqr'
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command
    EOS
  end

  it 'allows description to be optional' do
    cli = Cliqr.interface do
      basename 'my-command'
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command
    EOS
  end
end
