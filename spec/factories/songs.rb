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

FactoryGirl.define do
  factory :song do
    name 'MyString'
    artist 'MyString'
    art 'MyString'
    duration 1
    uri 'MyString'
    association :event, factory: :event
  end
end
