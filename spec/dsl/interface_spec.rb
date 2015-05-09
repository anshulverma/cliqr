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
    EOS
  end
end
