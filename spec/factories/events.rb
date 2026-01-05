FactoryBot.define do
  factory :event do
    title { "MyString" }
    description { "MyText" }
    start_time { "2026-01-05 21:02:51" }
    programmation { nil }
    session { nil }
  end
end
