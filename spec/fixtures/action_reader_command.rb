# encoding: utf-8

# A command that echoes the actions and options back
class ActionReaderCommand < Cliqr.command
  def execute(context)
    puts "command = #{context.command}\n\n"
    puts "executing action = #{context.action_name}" if context.action?
    context.options.each do |option|
      puts "[option] #{option.name} => #{option.value}"
    end
  end
end