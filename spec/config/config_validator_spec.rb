# encoding: utf-8

require 'spec_helper'

describe Cliqr::CLI::Validator do
  it 'does not allow empty config' do
    expect { Cliqr::CLI::Builder.new(nil).build }.to raise_error(Cliqr::Error::ConfigNotFound)
  end

  it 'does not allow empty basename' do
    config = Cliqr::CLI::Config.new
    config.basename = ''
    config.finalize
    expect { Cliqr::CLI::Builder.new(config).build }.to raise_error(Cliqr::Error::BasenameNotDefined)
  end

  it 'does not allow command handler to be null' do
    config = Cliqr::CLI::Config.new
    config.basename = 'my-command'
    config.finalize
    expect { Cliqr::CLI::Builder.new(config).build }.to raise_error(Cliqr::Error::HandlerNotDefined)
  end

  it 'only accepts command handler that extend from Cliqr::CLI::Command' do
    config = Cliqr::CLI::Config.new
    config.basename = 'my-command'
    config.handler = Object
    config.finalize
    expect { Cliqr::CLI::Builder.new(config).build }.to raise_error(Cliqr::Error::InvalidCommandHandler)
  end

  it 'expects that config options should not be nil' do
    config = Cliqr::CLI::Config.new
    config.basename = 'my-command'
    config.handler = TestCommand
    config.options = nil
    config.finalize
    expect { Cliqr::CLI::Builder.new(config).build }.to raise_error(Cliqr::Error::OptionsNotDefinedException)
  end
end
