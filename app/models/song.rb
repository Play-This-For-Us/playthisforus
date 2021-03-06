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
#  super_vote :boolean          default(FALSE), not null
#

# An entry in an event's playlist
class Song < ApplicationRecord
  belongs_to :event

  has_many :votes

  scope :active_queue, -> { where(queued_at: nil) }

  # Sort first by super votes, then vote count, then by time added, then by id
  # 1. This allows admins to have the absolute say on what's next
  # 2. Then, guests decide on popular vote (they also decide next super upvoted song if there is more than one)
  # 3. Then, in case of vote tie, the oldest song will be played next
  # 4. In the rare case of a tie, we just fallback to the id for predicitability
  scope :ranked, lambda {
    joins('LEFT JOIN votes ON songs.id = votes.song_id')
      .group('songs.id')
      .order('songs.super_vote DESC, coalesce(sum(votes.vote), 0) DESC NULLS LAST, songs.created_at ASC, songs.id ASC')
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

        false # the song wasn't "upvoted"
      else
        # the user already voted, change the vote to an upvote
        self.votes.find_by(user_identifier: user_identifier).upvote

        true # the song was "upvoted"
      end

    else
      # create a new upvote for the user
      self.votes.create!(user_identifier: user_identifier, vote: 1)

      true # the song was "upvoted"
    end
  end

  def downvote(user_identifier)
    vote = self.votes.where(user_identifier: user_identifier).first
    if vote.present?
      if vote.vote > 0
        # the user already voted, change the vote to a downvote
        self.votes.find_by(user_identifier: user_identifier).downvote

        true # the song was "downvoted"
      else
        # the user already downvoted this song, delete the downvote
        vote.destroy

        false # the song was "downvoted"
      end
    else
      # create a new downvote for the user
      self.votes.create!(user_identifier: user_identifier, vote: -1)

      true # the song was "downvoted"
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
