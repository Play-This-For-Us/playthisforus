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
#  score      :integer          not null
#  event_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Song < ApplicationRecord
  belongs_to :event

  has_many :votes

  def score
    # TODO(skovy) sum all votes
  end

  def upvote(user_identifier)
    if self.votes.exists?(user_identifier: user_identifier)
      # the user already voted, change the vote to an upvote
      self.votes.where(user_identifier: user_identifier).first.upvote
    else
      # create a new upvote for the user
      self.votes.create!(user_identifier: user_identifier, vote: 1)
    end
  end

  def downvote(user_identifier)
    if self.votes.exists?(user_identifier: user_identifier)
      # the user already voted, change the vote to a downvote
      self.votes.where(user_identifier: user_identifier).first.downvote
    else
      # create a new downvote for the user
      self.votes.create!(user_identifier: user_identifier, vote: -1)
    end
  end
end
