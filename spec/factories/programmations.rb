FactoryBot.define do
  factory :programmation do
    association :movie
    time { 1.day.from_now }
    max_tickets { 100 }
    price { 8.0 }
  end
end
