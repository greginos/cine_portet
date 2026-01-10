class Movie < ApplicationRecord
  validates :title, presence: true
  validates :imdb_id, uniqueness: true, allow_nil: true
  validates :url, format: { with: URI.regexp(%w[http https]), allow_blank: true }

  has_many :programmations, dependent: :restrict_with_error

  def self.ransackable_attributes(auth_object = nil)
    %w[
      title
      description
      duration
      genre
      director
      cast
      poster_url
      imdb_id
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      programmations
    ]
  end

  def director_hash
    case director
    when Hash
      director
    when String
      JSON.parse(director) rescue {}
    else
      {}
    end
  end

  def cast_array
    case cast
    when Array
      cast
    when String
      begin
        # Essayer JSON d'abord
        JSON.parse(cast)
      rescue JSON::ParserError
        # Si ça échoue, c'est probablement une string Ruby
        eval(cast) rescue []
      end
    else
      []
    end
  end

  def director_name
    director_hash["name"]
  end

  def actors
    cast_array
  end
end
