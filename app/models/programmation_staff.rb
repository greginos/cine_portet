class ProgrammationStaff < ApplicationRecord
  self.table_name = "programmation_staffs"

  belongs_to :programmation
  belongs_to :user

  enum :role, {
    projectionist: 0,
    opener: 1,
    ticket_seller: 2
  }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: [ :programmation_id, :role ], message: "est déjà assigné à ce rôle pour cette programmation" }

  ROLES = {
    projectionist: "Projectionniste",
    opener: "Ouvreur",
    ticket_seller: "Vendeur de billets"
  }.freeze

  def role_name
    ROLES[role.to_sym]
  end

  # Ajout des attributs recherchables pour Active Admin
  def self.ransackable_attributes(auth_object = nil)
    %w[
      created_at
      id
      programmation_id
      role
      updated_at
      user_id
    ]
  end

  # Ajout des associations recherchables pour Active Admin
  def self.ransackable_associations(auth_object = nil)
    %w[
      programmation
      user
    ]
  end
end
