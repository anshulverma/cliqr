# encoding: utf-8

require 'spec_helper'

require 'cliqr/cli/command_runner_factory'

describe Cliqr::CLI::CommandRunnerFactory do
  it 'returns standard runner for default output' do
    runner = Cliqr::CLI::CommandRunnerFactory.get(output: :default)
    expect(runner).to be_kind_of(Cliqr::CLI::StandardCommandRunner)
  end

  it 'returns buffered runner for buffer output' do
    runner = Cliqr::CLI::CommandRunnerFactory.get(output: :buffer)
    expect(runner).to be_kind_of(Cliqr::CLI::BufferedCommandRunner)
  end

  it 'throws error for default output type' do
    expect { Cliqr::CLI::CommandRunnerFactory.get(output: :unknown) }.to(
      raise_error(be_kind_of(Cliqr::Error::UnknownCommandRunnerException))
    )
  end
end
