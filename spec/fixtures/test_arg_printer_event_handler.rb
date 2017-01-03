# frozen_string_literal: true
# Event handler that prints arguments
class TestArgPrinterEventHandler < Cliqr.event_handler
  def handle(event, ch, num)
    puts event.name
    puts "#{ch} => #{num}"
  end
end
