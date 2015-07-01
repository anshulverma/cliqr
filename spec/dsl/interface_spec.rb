# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::Interface do
  it 'does not allow empty config' do
    expect do
      Cliqr::Interface.build(nil)
    end.to(raise_error(Cliqr::Error::ConfigNotFound, 'a valid config should be defined'))
  end

  it 'has options if added during build phase' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand

      option 'option-1' do
        short 'p'
        description 'a nice option to have'
      end
    end
    expect(cli.config.options?).to be_truthy
  end
end
