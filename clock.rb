require 'clockwork'

module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
  end

  every(5.seconds, 'queue.update') { puts "RUNNING" }
end
