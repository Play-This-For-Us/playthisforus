FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "testuser#{n}@playthisfor.us"}
    password "password"
    password_confirmation "password"
  end
end
