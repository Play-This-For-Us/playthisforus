# frozen_string_literal: true
# == Schema Information
#
# Table name: events
#
#  id                  :integer          not null, primary key
#  name                :string           not null
#  description         :text             not null
#  join_code           :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#  spotify_playlist_id :string
#  currently_playing   :boolean          default(FALSE), not null
#  pnator_enabled      :boolean
#  pnator_danceability :float
#  pnator_energy       :float
#  pnator_popularity   :float
#  pnator_speechiness  :float
#  pnator_happiness    :float
#  image_url           :text
#

FactoryGirl.define do
  factory :event do
    sequence(:name) { |n| "Event Name #{n}" }
    sequence(:description) { |n| "Cool Event Description #{n}" }
    sequence(:join_code) { |n| "abcdefg#{n}"}
    association :user, factory: :user
  end
end
