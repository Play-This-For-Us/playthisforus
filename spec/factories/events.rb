# frozen_string_literal: true
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

FactoryGirl.define do
  factory :event do
    sequence(:name) { |n| "Event Name #{n}" }
    sequence(:description) { |n| "Cool Event Description #{n}" }
    association :user, factory: :user
  end
end
