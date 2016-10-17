require 'clockwork'
require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
  end

  # TODO(skovy): consider running async - might run into issues otherwise
  every(10.seconds, 'queue.update') { QueueUpdate.perform }
end
