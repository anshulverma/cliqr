# encoding: utf-8

require 'spec_helper'

require 'cliqr/error'
require 'cliqr/executor/runner'

require 'fixtures/test_command'
require 'fixtures/always_error_command'
require 'fixtures/option_reader_command'
require 'fixtures/test_option_reader_command'
require 'fixtures/test_option_checker_command'
require 'fixtures/argument_reader_command'
require 'fixtures/test_option_type_checker_command'
require 'fixtures/csv_argument_operator'

describe Cliqr::Executor::Runner do
  it 'returns code 0 for default command runner' do
    expect(Cliqr.command.new.execute(nil)).to eq(0)
  end

  it 'routes base command with no arguments to command class' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
    end
    result = cli.execute_internal [], output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'routes base command with no arguments to command instance' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand.new
    end
    result = cli.execute_internal [], output: :buffer
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
    result = cli.execute_internal %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'lets a command get all option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler OptionReaderCommand

      option 'test-option'
    end
    result = cli.execute_internal %w(--test-option some-value), output: :buffer
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
    result = cli.execute_internal %w(--test-option some-value), output: :buffer
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

    result = cli.execute_internal %w(--test-option), output: :buffer
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

    result = cli.execute_internal %w(value1 --test-option qwerty value2 value3), output: :buffer
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

    result = cli.execute_internal %w(--test-option qwerty), output: :buffer
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

    result = cli.execute_internal %w(--test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type TrueClass
    EOS

    result = cli.execute_internal %w(--no-test-option), output: :buffer
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

    result = cli.execute_internal %w(--test-option 123), output: :buffer
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

    result = cli.execute_internal %w(--test-option a,b,c,d), output: :buffer
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

    result = cli.execute_internal %w(--test-option executor-inline), output: :buffer
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

    result = cli.execute_internal %w(--test-option operator-inline), output: :buffer
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
        puts action_type?
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
          puts action_type?
          puts option?('option-1')
          puts option?('option-2')
          puts option?('option-3')
        end

        option 'option-3'
      end
    end

    result = cli.execute_internal %w(--option-1 val1 --option-2 val2), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
in my-command
option-1 => val1
option-2 => val2
false
true
true
false
    EOS

    result = cli.execute_internal %w(my-action --option-3 val3), output: :buffer
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

    result = cli.execute_internal %w(--test_option executor-inline --second_option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
executor-inline
true
true
    EOS

    result = cli.execute_internal [], output: :buffer
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

    result = cli.execute_internal [], output: :buffer
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

    result = cli.execute_internal [], output: :buffer
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

    result = cli.execute_internal [], output: :buffer
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

    result = cli.execute_internal [], output: :buffer
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

    result = cli.execute_internal ['version'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
1234
    EOS
  end

  it 'can get version by option on base command' do
    cli = Cliqr.interface do
      name 'my-command'
      version '1234'
    end

    result = cli.execute_internal ['--version'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
1234
    EOS

    result = cli.execute_internal ['-v'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
1234
    EOS
  end

  it 'can not use version action on action command' do
    def define_interface
      Cliqr.interface do
        name 'my-command'

        action :bla do
          version '1234'
        end
      end
    end
    expect { define_interface }.to(raise_error(NoMethodError))
  end

  it 'can forward command to another action' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'

      action :action_1 do
        description 'test action'
        handler do
          puts 'in action_1'
          forward 'my_command action_2 sub-action' # starting with base command name
          puts 'back in action_1'
        end
      end

      action 'action_2' do
        handler do
          puts 'in action_2'
        end

        action 'sub-action' do
          handler do
            puts 'in sub-action'
            forward 'action_2' # not starting with base command name
            puts 'back in sub-action'
          end
        end
      end
    end

    result = cli.execute_internal ['action_1'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
in action_1
in sub-action
in action_2
back in sub-action
back in action_1
    EOS
  end

  it 'can forward command with space in arguments' do
    cli = Cliqr.interface do
      name :my_command

      action :foo do
        handler do
          forward 'bar --opt1 "simple value" --opt2 "a question"?'
        end
      end

      action :bar do
        option :opt1
        option :opt2

        handler do
          puts opt1
          puts opt2
        end
      end
    end

    result = cli.execute_internal ['foo'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
simple value
a question?
    EOS
  end

  describe 'error handling' do
    it 'returns 0 if no error' do
      cli = Cliqr.interface do
        name 'my-command'
        handler do
          puts 'I am happy!'
        end
      end

      old_stdout = $stdout
      $stdout = old_stdout.is_a?(StringIO) ? old_stdout : StringIO.new('', 'w')
      begin
        expect(cli.execute).to(eq(0))
        expect($stdout.string).to(eq("I am happy!\n"))
      ensure
        $stdout = old_stdout
      end
    end

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
        expect(cli.execute(['abcd'])).to(eq(101))
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
        expect(cli.execute(['abcd'])).to(eq(102))
        expect($stdout.string).to(eq("invalid command argument \"abcd\"\n"))
      ensure
        $stdout = old_stdout
      end
    end
  end

  it 'can get multiple values for an option' do
    cli = Cliqr.interface do
      name 'my-command'

      option 'foo' do
        multi_valued true
      end

      handler do
        puts foo
        puts foo.value
        puts foo.values.first
      end
    end

    result = cli.execute_internal %w(--foo v1 --foo v2 --foo v3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
v1,v2,v3
v1,v2,v3
v1
    EOS
  end

  it 'operates on multi option values' do
    cli = Cliqr.interface do
      name 'my-command'

      option 'foo' do
        multi_valued true
        type :numeric
      end

      option 'bar' do
        multi_valued true
        type :boolean
      end

      handler do
        puts foo
        puts foo.values.map(&:class)
        puts bar
        puts bar.values.map(&:class)
      end
    end

    result = cli.execute_internal %w(--foo 123 --foo 987 --bar --bar --no-bar), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
123,987
Fixnum
Fixnum
true,true,false
TrueClass
TrueClass
FalseClass
    EOS
  end
end
