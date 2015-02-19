require './scrapp'

module Clockwork
  handler { |job| puts job }

  every(1.hour, 'entries.refresh') { MyFreckle.new(Date.today.beginning_of_month, Date.today.end_of_month).fetch! }
end
