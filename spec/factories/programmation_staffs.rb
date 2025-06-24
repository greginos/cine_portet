FactoryBot.define do
  factory :programmation_staff do
    association :user
    association :programmation
    role { :projectionist }
  end
end
