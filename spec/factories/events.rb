FactoryGirl.define do
  factory :event do
    sequence(:name) { |n| "Event Name #{n}"}
    sequence(:description) { |n| "Cool Event Description #{n}"}
    association :user, factory: :user
  end
end
