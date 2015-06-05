# encoding: utf-8

require 'spec_helper'

describe Cliqr::CLI::Config do
  it 'sets proper defaults for unset values' do
    config = Cliqr::CLI::Config.new
    config.finalize
    expect(config.name).to eq('')
    expect(config.description).to eq('')
    expect(config.handler).to eq(nil)
    expect(config.options).to eq([])
  end
end
