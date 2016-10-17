class QueueUpdate
  def self.perform
    Event.all.each do |event|
      puts event.id
    end
  end
end
