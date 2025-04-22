class Programmation < ApplicationRecord
  validates :titre, :date, :heure, presence: true

  def fetch_movie_details
    return unless tmdb_id.present?

    movie = Tmdb::Movie.detail(tmdb_id)
    credits = Tmdb::Movie.credits(tmdb_id)

    self.titre = movie.title
    self.description = movie.overview
    self.genre = movie.genres.map { |g| g["name"] }.join(", ")
    self.duree = movie.runtime
    self.realisateur = credits.crew.find { |c| c["job"] == "Director" }&.dig("name")
    self.acteurs = credits.cast.take(3).map { |a| a["name"] }.join(", ")
    self.affiche_url = "https://image.tmdb.org/t/p/w500#{movie.poster_path}" if movie.poster_path

    save
  end

  def self.search_tmdb(query)
    Tmdb::Movie.find(query)
  end
end
