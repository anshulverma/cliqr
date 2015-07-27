# encoding: utf-8

require 'tempfile'

def with_input_output(lines, &block)
  old_stdin = $stdin
  old_stdout = $stdout
  input_file = Tempfile.new('cliqr').tap do |file|
    lines.push('exit').each { |line| file.write("#{line}\n") }
  end
  output_file = Tempfile.new('cliqr')
  begin
    $stdin = input_file.open
    $stdout = output_file.open
    output_getter = proc  do
      IO.read(output_file.path).gsub(/(.*)\n/, "\\1.\n")
    end
    block.call(output_getter)
  ensure
    $stdin = old_stdin
    $stdout = old_stdout
    input_file.close
    output_file.close
    input_file.unlink
    output_file.unlink
  end
end
