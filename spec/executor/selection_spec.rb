# encoding: utf-8

require 'spec_helper'

describe Cliqr::Command::CommandContext do
  it 'allows selection of an item from a list' do
    allow(Sawaal).to(receive(:select)).and_return(3)
    cli = Cliqr.interface do
      name 'my-command'
      handler do
        food_items = %w(pizza salad coke lasagna apple)
        selected = ask('what would you like?', food_items)
        puts selected
        puts food_items[selected]
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
3
lasagna
    EOS
  end
end
