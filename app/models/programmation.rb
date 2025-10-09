class Programmation < ApplicationRecord
  validates :time, presence: true
  validates :max_tickets, numericality: { greater_than: 0 }, allow_nil: true
  validates :normal_price, :member_price, :reduced_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  belongs_to :movie, optional: true
  belongs_to :session, optional: true

  has_many :programmation_staffs, dependent: :destroy
  has_many :staff_members, through: :programmation_staffs, source: :user
  has_many :tickets, dependent: :destroy
  accepts_nested_attributes_for :programmation_staffs, allow_destroy: true, reject_if: :all_blank

  before_validation :create_movie_from_imdb, if: -> { imdb_id.present? && movie.nil? }

  scope :in_session, ->(session) { where(session: session) }
  scope :without_session, -> { where(session_id: nil) }

  def projectionists
    staff_members.joins(:programmation_staffs).where(programmation_staffs: { role: :projectionist })
  end

  def openers
    staff_members.joins(:programmation_staffs).where(programmation_staffs: { role: :opener })
  end

  def ticket_sellers
    staff_members.joins(:programmation_staffs).where(programmation_staffs: { role: :ticket_seller })
  end

  def start_time
    time
  end

  def tickets_sold
    tickets.where(status: :paid).sum(:quantity)
  end

  def tickets_available?
    return true if max_tickets.nil?
    tickets_sold < max_tickets
  end

  def tickets_remaining
    return nil if max_tickets.nil?
    max_tickets - tickets_sold
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
    %w[
      time
      id
      imdb_id
      updated_at
      max_tickets
      normal_price
      member_price
      reduced_price
      created_at
      movie_id
      session_id
    ]
  end

  # Ajout des associations recherchables pour Active Admin
  def self.ransackable_associations(auth_object = nil)
    %w[
      programmation_staffs
      staff_members
      tickets
      movie
      session
    ]
  end

  def create_movie_from_imdb
    movie_details = ::MovieService.fetch_movie_details(imdb_id)
    return unless movie_details

    self.movie = Movie.create!(
      title: movie_details["title"],
      description: movie_details["description"],
      duration: movie_details["duration"],
      genre: movie_details["genre"],
      director: movie_details["director"],
      cast: movie_details["actors"],
      poster_url: movie_details["poster_url"],
      imdb_id: imdb_id
    )
  end
end
