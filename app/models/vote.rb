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
#

class Vote < ApplicationRecord
  belongs_to :song

  validates :user_identifier, presence: true
  validates :number, presence: true, inclusion: [-1, 0, 1]
end
