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

FactoryGirl.define do
  factory :vote do
    
  end

end
