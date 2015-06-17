# encoding: utf-8

require 'spec_helper'

require 'cliqr/error'

require 'fixtures/test_command'
require 'fixtures/always_error_command'
require 'fixtures/option_reader_command'
require 'fixtures/test_option_reader_command'
require 'fixtures/test_option_checker_command'
require 'fixtures/argument_reader_command'
require 'fixtures/test_option_type_checker_command'
require 'fixtures/csv_argument_operator'

describe Cliqr::CLI::Executor do
  it 'returns code 0 for default command runner' do
    expect(Cliqr.command.new.execute(nil)).to eq(0)
  end

  it 'routes base command with no arguments to command class' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
    end
    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'routes base command with no arguments to command instance' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand.new
    end
    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'handles error appropriately' do
    cli = Cliqr.interface do
      name 'my-command'
      handler AlwaysErrorCommand
    end
    expect { cli.execute_internal [] }.to(
      raise_error(Cliqr::Error::CommandRuntimeError,
                  "command 'my-command' failed\n\nCause: StandardError - I always throw an error\n"))
  end

  it 'routes a command with option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'lets a command get all option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler OptionReaderCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my-command

[option] test-option => some-value
    EOS
  end

  it 'lets a command get single option value' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
some-value
    EOS
  end

  it 'handles executor error cause properly' do
    cli = Cliqr.interface do
      name 'my-command'
      handler AlwaysErrorCommand
    end
    begin
      cli.execute
    rescue Cliqr::Error::CliqrError => e
      expect(e.backtrace[0]).to end_with "cliqr/spec/fixtures/always_error_command.rb:6:in `execute'"
      expect(e.message).to eq "command 'my-command' failed\n\nCause: StandardError - I always throw an error\n"
    end
  end

  it 'allows command to check if an option exists or not' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestOptionCheckerCommand

      option 'test-option' do
        type :boolean
      end
    end

    result = cli.execute %w(--test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is defined
    EOS
  end

  it 'allows command to access argument list' do
    cli = Cliqr.interface do
      name 'my-command'
      handler ArgumentReaderCommand
      arguments :enable

      option 'test-option'
    end

    result = cli.execute %w(value1 --test-option qwerty value2 value3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
value1
value2
value3
    EOS
  end

  it 'properly handles string type arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionTypeCheckerCommand

      option 'test-option'
    end

    result = cli.execute %w(--test-option qwerty), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type String
    EOS
  end

  it 'properly handles boolean type arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionTypeCheckerCommand

      option 'test-option' do
        type :boolean
      end
    end

    result = cli.execute %w(--test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type TrueClass
    EOS

    result = cli.execute %w(--no-test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type FalseClass
    EOS
  end

  it 'properly handles integer type arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionTypeCheckerCommand

      option 'test-option' do
        type :numeric
      end
    end

    result = cli.execute %w(--test-option 123), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type Fixnum
    EOS
  end

  it 'allows custom argument operators' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        operator CSVArgumentOperator
      end
    end

    result = cli.execute %w(--test-option a,b,c,d), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
a
b
c
d
    EOS
  end

  it 'allows inline executor' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts "value = #{option('test-option').value}"
      end

      option 'test-option'
    end

    result = cli.execute %w(--test-option executor-inline), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
value = executor-inline
    EOS
  end

  it 'allows inline argument operator' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        operator do
          "value = #{value}"
        end
      end
    end

    result = cli.execute %w(--test-option operator-inline), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
value = operator-inline
    EOS
  end

  it 'allows inline executor to access all context methods directly' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts 'in my-command'
        puts options.map { |option| "#{option.name} => #{option.value}" }
        puts action?
        puts option?('option-1')
        puts option?('option-2')
        puts option?('option-3')
      end

      option 'option-1'
      option 'option-2'

      action 'my-action' do
        handler do
          puts 'in my-action'
          puts options.map { |option| "#{option.name} => #{option.value}" }
          puts option('option-3').value
          puts action?
          puts option?('option-1')
          puts option?('option-2')
          puts option?('option-3')
        end

        option 'option-3'
      end
    end

    result = cli.execute %w(--option-1 val1 --option-2 val2), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
in my-command
option-1 => val1
option-2 => val2
false
true
true
false
    EOS

    result = cli.execute %w(my-action --option-3 val3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
in my-action
option-3 => val3
val3
true
false
false
true
    EOS
  end

  it 'allows inline executor to get option value by calling method' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
        puts second_option
      end

      option 'test_option'

      option 'second_option' do
        type :boolean
      end
    end

    result = cli.execute %w(--test_option executor-inline --second_option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
executor-inline
true
true
    EOS

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS

false
false
    EOS
  end

  it 'makes false the default for boolean options' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option 'test_option' do
        type :boolean
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
false
false
    EOS
  end

  it 'can override default to true' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option 'test_option' do
        type :boolean
        default true
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
true
false
    EOS
  end

  it 'makes 0 as default for numerical' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option 'test_option' do
        type :numeric
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
0
false
    EOS
  end

  it 'allows non-zero default for numerical option' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option :test_option do
        type :numeric
        default 123
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
123
false
    EOS
  end

  it 'can use version action on base command' do
    cli = Cliqr.interface do
      name 'my-command'
      version '1234'
    end

    result = cli.execute ['version'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
1234
    EOS
  end

  it 'can get version by option on base command' do
    cli = Cliqr.interface do
      name 'my-command'
      version '1234'
    end

    result = cli.execute ['--version'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
1234
    EOS

    result = cli.execute ['-v'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
1234
    EOS
  end

  it 'can use version action on action command' do
    cli = Cliqr.interface do
      name 'my-command'

      action :bla do
        version '1234'
      end
    end

    result = cli.execute ['bla version'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
1234
    EOS
  end

  describe 'error handling' do
    it 'can handle errors in command handler' do
      cli = Cliqr.interface do
        name 'my-command'
        handler do
          fail StandardError, 'I am not a happy handler!'
        end
      end

      old_stdout = $stdout
      $stdout = old_stdout.is_a?(StringIO) ? old_stdout : StringIO.new('', 'w')
      begin
        expect(cli.execute(['abcd'])).to(eq(1))
        expect($stdout.string).to(eq("command 'my-command' failed\n\nCause: StandardError - I am not a happy handler!\n"))
      ensure
        $stdout = old_stdout
      end
    end

    it 'can handle errors in command arguments' do
      cli = Cliqr.interface do
        name 'my-command'
        arguments :disable
      end

      old_stdout = $stdout
      $stdout = old_stdout.is_a?(StringIO) ? old_stdout : StringIO.new('', 'w')
      begin
        expect(cli.execute(['abcd'])).to(eq(2))
        expect($stdout.string).to(eq("invalid command argument \"abcd\"\n"))
      ensure
        $stdout = old_stdout
      end
    end
  end
end
