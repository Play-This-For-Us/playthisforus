# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text             not null
#  join_code   :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#

class Event < ApplicationRecord
  JOIN_CODE_LENGTH = 8

  belongs_to :user

  validates :name, presence: true
  validates :description, presence: true

  has_secure_token :join_code

  # create a random code to join the event
  before_create :set_join_code

  def avatar_image
    # we currently have 5 default images
    "events/#{(self.id % 4) + 1}.jpg"
  end

private

  def set_join_code
    self.join_code = generate_join_code
  end

  def generate_join_code
    loop do
      token = (0...JOIN_CODE_LENGTH).map { ('a'..'z').to_a[rand(26)] }.join
      break token unless Event.where(join_code: token).exists?
    end
  end
end
