# frozen_string_literal: true
# Event handler that invokes another event
class TestInvokerEventHandler < Cliqr.event_handler
  def handle(event, ch, num)
    puts "invoked #{event.name} : #{event.command} : #{ch} : #{num}"
    invoke :foo, 'b', 2, t: 1
  end
end
