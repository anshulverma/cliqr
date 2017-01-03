# frozen_string_literal: true
require 'argument_parser_spec_helper'

describe Cliqr::Parser do
  it 'can parse a command with an action' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand
      end
    end
    config = cli.config
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {})
    assert_results(config, ['my-action'], parsed_input, config.action('my-action'))
  end

  it 'can parse a command with a nested action' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action-1' do
        handler TestCommand

        action 'my-action-2' do
          handler TestCommand

          action 'my-action-3' do
            handler TestCommand
          end
        end
      end
    end
    config = cli.config
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {})
    assert_results(config, %w(my-action-1 my-action-2 my-action-3), parsed_input,
                   config.action('my-action-1').action('my-action-2').action('my-action-3'))
  end

  it 'can parse a command with an action and options' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand

        option 'test-option-1' do
          short 't'
        end

        option 'test-option-2' do
          short 'p'
        end
      end
    end
    config = cli.config
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {
                                                    'test-option-1' => ['abcd'],
                                                    'test-option-2' => ['qwe']
                                                  })
    assert_results(config, %w(my-action -t abcd --test-option-2 qwe), parsed_input, config.action('my-action'))
  end

  it 'can parse a command with nested action and options' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action-1' do
        handler TestCommand

        action 'my-action-2' do
          handler TestCommand

          option 'test-option-1' do
            short 't'
          end

          option 'test-option-2' do
            short 'p'
          end
        end
      end
    end
    config = cli.config
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {
                                                    'test-option-1' => ['abcd'],
                                                    'test-option-2' => ['qwe']
                                                  })
    assert_results(config, %w(my-action-1 -t abcd --test-option-2 qwe my-action-2), parsed_input,
                   config.action('my-action-1').action('my-action-2'))
  end
end
