# encoding: utf-8

require 'spec_helper'

describe Cliqr::Executor::CommandRunnerFactory do
  it 'returns standard runner for default output' do
    runner = Cliqr::Executor::CommandRunnerFactory.get(output: :default)
    expect(runner).to be_kind_of(Cliqr::Executor::StandardCommandRunner)
  end

  it 'returns buffered runner for buffer output' do
    runner = Cliqr::Executor::CommandRunnerFactory.get(output: :buffer)
    expect(runner).to be_kind_of(Cliqr::Executor::BufferedCommandRunner)
  end

  it 'throws error for default output type' do
    expect { Cliqr::Executor::CommandRunnerFactory.get(output: :unknown) }.to(
      raise_error(be_kind_of(Cliqr::Error::UnknownCommandRunnerException))
    )
  end
end
