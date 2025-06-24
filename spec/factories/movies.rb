FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Movie #{n}" }
    sequence(:imdb_id) { |n| "tt#{n.to_s.rjust(7, '0')}" }
    description { "A great movie" }
    duration { 120 }
    genre { "Action" }
    director { "John Director" }
    cast { "Actor 1, Actor 2" }
    poster_url { "https://example.com/poster.jpg" }
  end
end
