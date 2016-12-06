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

FactoryGirl.define do
  factory :vote do
    sequence(:user_identifier) { |n| "unique-indentifier-#{n}" }
    vote(-1)
    association :song, factory: :song
  end
end
