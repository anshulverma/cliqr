# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::Command::Color do
  it 'allows use of several colors in the command handler' do
    cli = Cliqr.interface do
      name 'my-command'
      handler do
        [
          :black,
          :red,
          :green,
          :yellow,
          :blue,
          :magenta,
          :cyan,
          :gray,
          :bg_black,
          :bg_red,
          :bg_green,
          :bg_yellow,
          :bg_blue,
          :bg_magenta,
          :bg_cyan,
          :bg_gray,
          :bold,
          :reverse_color
        ].each do |color|
          puts method(color).call("this should be #{color}")
        end
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
[30mthis should be black[0m
[31mthis should be red[0m
[32mthis should be green[0m
[33mthis should be yellow[0m
[34mthis should be blue[0m
[35mthis should be magenta[0m
[36mthis should be cyan[0m
[37mthis should be gray[0m
[40mthis should be bg_black[0m
[41mthis should be bg_red[0m
[42mthis should be bg_green[0m
[43mthis should be bg_yellow[0m
[44mthis should be bg_blue[0m
[45mthis should be bg_magenta[0m
[46mthis should be bg_cyan[0m
[47mthis should be bg_gray[0m
[1mthis should be bold[22m
[7mthis should be reverse_color[27m
    EOS
  end

  it 'allows use of color in action' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action :foo do
        handler do
          puts red('this should be colorized in red')
        end
      end
    end
    result = cli.execute_internal ['my-command foo'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
\e[31mthis should be colorized in red\e[0m
    EOS
  end

  it 'allows disabling colors in command' do
    cli = Cliqr.interface do
      name 'my-command'
      color :disable
      handler do
        puts red('this should not be colorized')
      end
    end
    result = cli.execute_internal ['my-command'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
this should not be colorized
    EOS
  end

  it 'allows disabling colors in action' do
    cli = Cliqr.interface do
      name 'my-command'
      color :disable

      action :foo do
        handler do
          puts red('this should not be colorized')
        end
      end
    end
    result = cli.execute_internal ['my-command foo'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
this should not be colorized
    EOS
  end

  it 'allows disabling colors in deeply nested action' do
    cli = Cliqr.interface do
      name 'my-command'
      color :disable

      action :foo do
        action :bar do
          handler do
            puts red('this should not be colorized')
          end
        end
      end
    end
    result = cli.execute_internal ['my-command foo bar'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
this should not be colorized
    EOS
  end
end
