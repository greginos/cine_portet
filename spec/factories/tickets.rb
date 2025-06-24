FactoryBot.define do
  factory :ticket do
    association :programmation
    quantity { 2 }
    total_price { 16.0 }
    status { :pending }
  end
end
