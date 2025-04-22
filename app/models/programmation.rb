class Programmation < ApplicationRecord
  validates :date, :heure, presence: true
  validates :titre, presence: true, unless: -> { imdb_id.present? }
  validates :imdb_id, presence: true, if: -> { titre.blank? }

  after_create :fetch_movie_details, if: -> { imdb_id.present? }
  after_update :fetch_movie_details, if: :imdb_id_changed?

  def start_time
    date.to_datetime + heure.seconds_since_midnight.seconds
  end

  def fetch_movie_details
    return unless imdb_id.present?

    # Trouver d'abord l'ID TMDB à partir de l'ID IMDB
    find_result = Tmdb::Find.movie(imdb_id, external_source: "imdb_id")
    return unless find_result.any?

    tmdb_id = find_result.first["id"]
    movie = Tmdb::Movie.detail(tmdb_id)
    # credits = Tmdb::Movie.credits(tmdb_id)

    self.titre = movie.title
    self.description = movie.overview
    self.genre = movie.genres.map { |g| g["name"] }.join(", ")
    self.duree = movie.runtime
    # self.realisateur = credits.crew.find { |c| c["job"] == "Director" }&.dig("name")
    # self.acteurs = credits.cast.take(3).map { |a| a["name"] }.join(", ")
    self.affiche_url = "https://image.tmdb.org/t/p/w500#{movie.poster_path}" if movie.poster_path

    save
  end

  def self.search_tmdb(query)
    # Si le query ressemble à un ID IMDB (commence par 'tt')
    if query.start_with?("tt")
      find_result = Tmdb::Find.movie(query, external_source: "imdb_id")
      return find_result
    end

    # Sinon, faire une recherche normale
    Tmdb::Movie.find(query)
  end

  # Ajout des attributs recherchables pour Active Admin
  def self.ransackable_attributes(auth_object = nil)
    [ "acteurs", "affiche_url", "created_at", "date", "description", "duree", "genre", "heure", "id", "realisateur", "titre", "imdb_id", "updated_at" ]
  end

  # Ajout des associations recherchables pour Active Admin
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
