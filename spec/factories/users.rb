FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "John" }
    family_name { "Doe" }
  end
end
