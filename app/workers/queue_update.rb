class QueueUpdate
  def self.perform
    Event.all.currently_playing.each do |event|
      puts event.id
    end
  end
end
