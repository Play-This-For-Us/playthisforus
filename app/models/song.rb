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

  # Sort first by vote count, then by time added, then by id
  scope :ranked, lambda {
    joins('LEFT JOIN votes ON songs.id = votes.song_id')
      .group('songs.id')
      .order('coalesce(sum(votes.vote), 0) DESC NULLS LAST, songs.created_at, songs.id')
  }

  def score
    self.votes.sum(:vote)
  end

  def upvote(user_identifier)
    vote =  self.votes.where(user_identifier: user_identifier).first
    if vote.present?
    if vote.vote > 0
        # the user already upvoted this song, delete the upvote
        vote.destroy
      else
        # the user already voted, change the vote to an upvote
        self.votes.find_by(user_identifier: user_identifier).upvote
      end

    else
      # create a new upvote for the user
      self.votes.create!(user_identifier: user_identifier, vote: 1)
    end
  end

  def downvote(user_identifier)
    vote = self.votes.where(user_identifier: user_identifier).first
    if vote.present?
      if vote.vote > 0
        # the user already voted, change the vote to a downvote
        self.votes.find_by(user_identifier: user_identifier).downvote
      else
        # the user already downvoted this song, delete the downvote
        vote.destroy
      end
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
    ActionCable.server.broadcast self.event.channel_name, action: 'remove-song', data: self
  end

  def destroyer
    ActionCable.server.broadcast self.event.channel_name, action: 'remove-song', data: self
    self.destroy
  end

  def as_json(options = {})
    h = super(options)
    h[:score] = score
    h
  end
end
