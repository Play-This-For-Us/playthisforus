# frozen_string_literal: true
# == Schema Information
#
# Table name: songs
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  artist     :string           not null
#  art        :string           not null
#  duration   :integer          not null
#  uri        :string           not null
#  event_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  queued_at  :datetime
#

# An entry in an event's playlist
class Song < ApplicationRecord
  belongs_to :event

  has_many :votes

  scope :active_queue, -> { where(queued_at: nil) }

  scope :ranked, -> { joins('LEFT JOIN votes ON songs.id = votes.song_id').group('songs.id').order('sum(votes.vote) DESC NULLS LAST') }

  def score
    self.votes.sum(:vote)
  end

  def upvote(user_identifier)
    if self.votes.exists?(user_identifier: user_identifier)
      # the user already voted, change the vote to an upvote
      self.votes.find_by(user_identifier: user_identifier).upvote
    else
      # create a new upvote for the user
      self.votes.create!(user_identifier: user_identifier, vote: 1)
    end
  end

  def downvote(user_identifier)
    if self.votes.exists?(user_identifier: user_identifier)
      # the user already voted, change the vote to a downvote
      self.votes.find_by(user_identifier: user_identifier).downvote
    else
      # create a new downvote for the user
      self.votes.create!(user_identifier: user_identifier, vote: -1)
    end
  end

  def to_spotify_track
    RSpotify::Track.new(self)
  end

  def remove_from_queue
    self.update(queued_at: Time.now.utc)
    EventChannel.broadcast_to(@event, { action: "remove", song: self })
  end

  def as_json(options = {})
    h = super(options)
    h[:score] = score
    h
  end
end
