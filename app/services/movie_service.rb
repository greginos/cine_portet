class MovieService
  class << self
    def fetch_movie_details(imdb_id)
      return unless imdb_id.present?

      # Si le query ressemble à un ID IMDB (commence par 'tt')
      if imdb_id.start_with?("tt")
        find_result = Tmdb::Find.movie(imdb_id, external_source: "imdb_id")
        return unless find_result.any?

        tmdb_id = find_result.first["id"]
        movie = Tmdb::Movie.detail(tmdb_id)
        cast = Tmdb::Movie.cast(tmdb_id)
        crew = Tmdb::Movie.crew(tmdb_id)

        {
          "title" => movie.title,
          "description" => movie.overview,
          "genre" => movie.genres.map { |g| g["name"] }.join(", "),
          "duration" => movie.runtime,
          "director" => {
            "name" => crew.find { |c| c["job"] == "Director" }&.dig("name"),
            "profile_picture" => crew.find { |c| c["job"] == "Director" }&.dig("profile_path") ? "https://image.tmdb.org/t/p/w500#{crew.find { |c| c['job'] == 'Director' }['profile_path']}" : nil
          },
          "actors" => cast.take(4).map do |actor|
            {
              "name" => actor["name"],
              "profile_picture" => actor["profile_path"] ? "https://image.tmdb.org/t/p/w500#{actor['profile_path']}" : nil
            }
          end,
          "poster_url" => movie.poster_path ? "https://image.tmdb.org/t/p/w500#{movie.poster_path}" : nil
        }
      end
    end
  end
end
