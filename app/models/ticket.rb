class Ticket < ApplicationRecord
  belongs_to :programmation

  TICKET_TYPES = {
    normal: "Normal",
    member: "Adhérent",
    reduced: "Réduit"
  }.freeze

  STATUSES = {
    pending: "En attente",
    paid: "Payé",
    cancelled: "Annulé"
  }.freeze

  validates :ticket_type, presence: true, inclusion: { in: TICKET_TYPES.keys.map(&:to_s) }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES.keys.map(&:to_s) }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  def total_price
    price * quantity
  end

  def ticket_type_name
    TICKET_TYPES[ticket_type.to_sym]
  end

  def status_name
    STATUSES[status.to_sym]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      programmation_id
      ticket_type
      price
      quantity
      status
      stripe_session_id
      email
      name
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[programmation]
  end
end
