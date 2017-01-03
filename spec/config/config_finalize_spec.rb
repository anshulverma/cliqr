# frozen_string_literal: true
require 'spec_helper'

describe Cliqr::Config do
  it 'sets proper defaults for unset values' do
    config = Cliqr::Config::Command.new
    config.finalize
    expect(config.name).to eq('')
    expect(config.description).to eq('')
    expect(config.handler).to eq(nil)
    expect(config.options).to eq({})
  end
end
