# frozen_string_literal: true
# A command that echoes the options back
class OptionReaderCommand < Cliqr.command
  def execute(context)
    puts "#{context.command}\n\n"
    context.options.each do |option|
      puts "[option] #{option.name} => #{option.value}"
    end
  end
end
