# frozen_string_literal: true
# == Schema Information
#
# Table name: votes
#
#  id              :integer          not null, primary key
#  user_identifier :string           not null
#  vote            :integer          not null
#  song_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  super_vote      :boolean          default(FALSE), not null
#

class Vote < ApplicationRecord
  belongs_to :song

  validates :user_identifier, presence: true
  validates :vote, presence: true, inclusion: [-1, 0, 1]
  validates :song, presence: true

  scope :upvotes, -> { where(vote: 1).count }
  scope :downvotes, -> { where(vote: -1).count }

  def upvote
    self.update!(vote: 1)
  end

  def downvote
    self.update!(vote: -1)
  end
end
