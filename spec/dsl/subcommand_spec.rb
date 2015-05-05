require 'spec_helper'

describe Cliqr do
  it 'builds a base command with name' do
    cli = Cliqr.interface do
      basename 'tinbox'
    end

    expect(cli.usage).to eq <<-EOS
        USAGE: tinbox
      EOS
  end
end
