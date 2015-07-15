# encoding: utf-8

require 'spec_helper'

require 'cliqr/events/handler'

require 'fixtures/test_arg_printer_event_handler'
require 'fixtures/test_empty_event_handler'
require 'fixtures/test_invoker_event_handler'

describe Cliqr::Events::Handler do
  it 'allows invoking event that does not have a handler' do
    cli = Cliqr.interface do
      name 'my-command'
      handler do
        puts invoke :base, 'a', 1
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
false
    EOS
  end

  it 'allows a custom class as event handler' do
    cli = Cliqr.interface do
      name 'my-command'
      on :base, TestArgPrinterEventHandler
      handler do
        puts invoke :base, 'a', 1
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
base
a => 1
true
    EOS
  end

  it 'does not allow missing handle method in handler' do
    cli = Cliqr.interface do
      name 'my-command'
      on :base, TestEmptyEventHandler
      handler do
        puts invoke :base, 'a', 1
      end
    end
    expect { cli.execute_internal ['my-command'] }.to(
      raise_error(Cliqr::Error::CommandRuntimeError,
                  "command 'my-command' failed\n\n" \
                    "Cause: Cliqr::Error::InvocationError - failed invocation for base\n\n" \
                      "Cause: Cliqr::Error::InvocationError - handle method not implemented by handler class\n\n"))
  end

  it 'handles errors in invocation handlers' do
    cli = Cliqr.interface do
      name 'my-command'
      on :base do
        fail StandardError, 'kaboom!'
      end
      handler do
        puts invoke :base
      end
    end
    expect { cli.execute_internal ['my-command'] }.to(
      raise_error(Cliqr::Error::CommandRuntimeError,
                  "command 'my-command' failed\n\n" \
                    "Cause: Cliqr::Error::InvocationError - failed invocation for base\n\n" \
                      "Cause: StandardError - kaboom!\n\n"))
  end

  it 'allows a proc as event handler' do
    cli = Cliqr.interface do
      name 'my-command'
      on :base do |_event, ch, num|
        puts "invoked : #{ch} : #{num}"
      end
      handler do
        puts invoke :base, 'a', 1
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked : a : 1
true
    EOS
  end

  it 'allows a string as event name' do
    cli = Cliqr.interface do
      name 'my-command'
      on 'my-event-name' do |_event, ch, num|
        puts "invoked : #{ch} : #{num}"
      end
      handler do
        puts invoke 'my-event-name', 'a', 1
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked : a : 1
true
    EOS
  end

  it 'allows access to event properties in event handler' do
    cli = Cliqr.interface do
      name 'my-command'
      on :base do |event, ch, num|
        puts "invoked : #{ch} : #{num}"
        puts event.name
        puts event.command
        puts event.timestamp.class
      end
      handler do
        invoke :base, 'a', 1
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked : a : 1
base
my-command
Time
    EOS
  end

  it 'allows invoking a event handler from other event handler' do
    cli = Cliqr.interface do
      name 'my-command'
      on :foo do |event, ch, num, hash|
        puts "invoked #{event.name} : #{event.command} : #{ch} : #{num} : #{hash}"
        puts "#{event.name} #{(event.parent? ? "has parent => #{event.parent.name}" : 'does not have parent')}"
        puts "parent: #{event.parent.name} : #{event.parent.command}"
        puts "diff => #{event.timestamp.to_i - event.parent.timestamp.to_i}"
        puts "diff => #{event.parent.timestamp.to_i - event.parent.parent.timestamp.to_i}"
        puts "#{event.name} ending"
      end

      action :my_action do
        on :bar do |event, ch, num|
          puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
          puts "#{event.name} #{(event.parent? ? "has parent => #{event.parent.name}" : 'does not have parent')}"
          sleep 1
          invoke :baz, 'b', 2, :t => 1
          puts "#{event.name} ending"
        end
        on :baz do |event, ch, num, hash|
          puts "invoked #{event.name} : #{event.command} : #{ch} : #{num} : #{hash}"
          puts "#{event.name} #{(event.parent? ? "has parent => #{event.parent.name}" : 'does not have parent')}"
          puts "parent: #{event.parent.name} : #{event.parent.command}"
          puts "diff => #{event.timestamp.to_i - event.parent.timestamp.to_i}"
          sleep 1
          invoke :foo, 'c', 3, :s => 2
          puts "#{event.name} ending"
        end
        handler do
          puts 'invoked action'
          invoke :bar, 'a', 1
          puts 'action ending'
        end
      end
    end
    result = cli.execute_internal 'my-command my_action', output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked action
invoked bar : my-command my_action : a : 1
bar does not have parent
invoked baz : my-command my_action : b : 2 : {:t=>1}
baz has parent => bar
parent: bar : my-command my_action
diff => 1
invoked foo : my-command my_action : c : 3 : {:s=>2}
foo has parent => baz
parent: baz : my-command my_action
diff => 1
diff => 1
foo ending
baz ending
bar ending
action ending
    EOS
  end

  it 'allows invoking a event handler from custom event handler class' do
    cli = Cliqr.interface do
      name 'my-command'
      on :foo do |event, ch, num, hash|
        puts "invoked #{event.name} : #{event.command} : #{ch} : #{num} : #{hash}"
        puts event.parent.name
      end

      action :my_action do
        on :bar, TestInvokerEventHandler
        handler do
          invoke :bar, 'a', 1
        end
      end
    end
    result = cli.execute_internal 'my-command my_action', output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked bar : my-command my_action : a : 1
invoked foo : my-command my_action : b : 2 : {:t=>1}
bar
    EOS
  end

  it 'invokes event handler by propogating up the action chain' do
    cli = Cliqr.interface do
      name 'my-command'
      on :first do |event, ch, num|
        puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
      end
      on :second do |event, ch, num|
        puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
      end
      on :third do |event, ch, num|
        puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
      end
      handler do
        invoke :first, 'a', 1 # should only call one of base command
      end

      action :foo do
        on :first do |event, ch, num|
          puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
        end
        on :second do |event, ch, num|
          puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
        end
        handler do
          invoke :second, 'b', 2 # invokes this and base
        end

        action :bar do
          on :first do |event, ch, num|
            puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
          end
          on :third do |event, ch, num|
            puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
          end
          handler do
            invoke :first, 'b', 2 # invokes all the way to base
            invoke :third, 'd', 4 # invokes this and base (skips parent)
          end
        end

        action :baz do
          on :second do |event, ch, num|
            puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
          end
          handler do
            invoke :second, 'e', 5 # invokes all the way to base (skips sibling)
          end
        end
      end
    end
    result = cli.execute_internal 'my-command', output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked first : my-command : a : 1
    EOS
    result = cli.execute_internal 'my-command foo', output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked second : my-command foo : b : 2
invoked second : my-command foo : b : 2
    EOS
    result = cli.execute_internal 'my-command foo bar', output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked first : my-command foo bar : b : 2
invoked first : my-command foo bar : b : 2
invoked first : my-command foo bar : b : 2
invoked third : my-command foo bar : d : 4
invoked third : my-command foo bar : d : 4
    EOS
    result = cli.execute_internal 'my-command foo baz', output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked second : my-command foo baz : e : 5
invoked second : my-command foo baz : e : 5
invoked second : my-command foo baz : e : 5
    EOS
  end

  it 'can terminate event chain' do
    cli = Cliqr.interface do
      name 'my-command'
      on :base do
        puts 'should not be invoked'
      end

      action :foo do
        on :base do |event|
          puts 'should be invoked'
          event.stop_propagation
        end
        handler do
          invoke :base
        end
      end
    end
    result = cli.execute_internal %w(my-command foo), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
should be invoked
    EOS
  end

  it 'can access options in event handler' do
    cli = Cliqr.interface do
      name 'my-command'
      on :foo do
        puts 'invoked foo'
        puts opt?
        puts abc?
        puts xyz?
        puts opt
      end

      action :my_action do
        on :bar do
          puts 'invoked bar'
          puts opt?
          puts abc?
          puts xyz?
          puts opt
        end

        handler do
          invoke :bar, 'a', 1
        end

        option :opt
        option :abc
      end
    end
    result = cli.execute_internal 'my-command my_action --opt val', output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked bar
true
false

val
    EOS
  end

  it 'cannot get option value for non-configured option' do
    cli = Cliqr.interface do
      name 'my-command'

      on :foo do
        puts 'invoked foo'
        puts opt
      end

      handler do
        invoke :foo
      end
    end

    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
invoked foo

    EOS
  end
end
