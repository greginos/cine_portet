class User < ApplicationRecord
  has_many :programmation_staff
  has_many :staffed_programmations, through: :programmation_staff, source: :programmation

  validates :first_name, :family_name, :email, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def staffed_programmations_by_role(role)
    staffed_programmations.where(programmation_staff: { role: role })
  end

  def full_name
    if first_name.present? && family_name.present?
      "#{first_name} #{family_name}"
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
      family_name
      first_name
      id
      remember_created_at
      reset_password_sent_at
      reset_password_token
      updated_at
      sign_in_token
      token_expires_at
    ]
  end

  # Ajout des associations recherchables pour Active Admin
  def self.ransackable_associations(auth_object = nil)
    %w[
      programmation_staff
      staffed_programmations
    ]
  end
end
