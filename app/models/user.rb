class User < ApplicationRecord
  has_many :programmation_staffs
  has_many :staffed_programmations, through: :programmation_staffs, source: :programmation

  enum :membership_type, { simple: 0, couple: 1, soutien: 2, couple_soutien: 3 }
  validates :first_name, :last_name, :email, :membership_type, presence: true
  validates :paid, inclusion: { in: [ true, false ], message: "doit être précisé (cotisation payée ou non)" }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :volunteers, -> { where.not(teams: [ nil, "", [] ]) }
  scope :members, -> { where(teams: [ nil, "", [] ]) }

  def volunteer?
    teams.present? && teams.any?
  end

  def member?
    !volunteer?
  end

  def role
    volunteer? ? "volunteer" : "member"
  end


  TEAMS = %w[ticketing projection communication movie_selection opener other].freeze

  serialize :teams, type: Array, coder: JSON

  def staffed_programmations_by_role(role)
    staffed_programmations.where(programmation_staff: { role: role })
  end

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    else
      email
    end
  end

  # Méthodes pour les magic links
  def generate_sign_in_token!
    token = SecureRandom.urlsafe_base64(32)
    update!(
      sign_in_token: token,
      token_expires_at: 24.hours.from_now
    )
    token
  end

  def sign_in_token_valid?
    sign_in_token.present? && token_expires_at > Time.current
  end

  def invalidate_sign_in_token!
    update!(sign_in_token: nil, token_expires_at: nil)
  end

  # Ajout des attributs recherchables pour Active Admin
  def self.ransackable_attributes(auth_object = nil)
    %w[
      created_at
      email
      last_name
      first_name
      id
      remember_created_at
      reset_password_sent_at
      reset_password_token
      updated_at
      sign_in_token
      token_expires_at
      paid
      membership_type
      phone
      address
      zip_code
      city
      country
      member_number
      teams
    ]
  end

  # Ajout des associations recherchables pour Active Admin
  def self.ransackable_associations(auth_object = nil)
    %w[
      programmation_staffs
      staffed_programmations
    ]
  end
end
