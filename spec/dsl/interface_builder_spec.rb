# encoding: utf-8

require 'spec_helper'

describe Cliqr::CLI::Builder do
  it 'does not allow empty config' do
    expect { Cliqr::CLI::Builder.new(nil) }.to raise_error(Cliqr::Error::ConfigNotFound)
  end
end
