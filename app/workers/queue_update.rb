# frozen_string_literal: true

class QueueUpdate
  def self.perform
    Event.all.currently_playing.each do |event|
      puts "Updating queue for event##{event.id}"
      event.check_queue
    end
  end
end
