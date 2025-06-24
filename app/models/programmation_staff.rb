class ProgrammationStaff < ApplicationRecord
  self.table_name = "programmation_staffs"

  belongs_to :programmation
  belongs_to :user

  # Définition des rôles avec leurs valeurs numériques
  ROLES = {
    projectionist: "Projectionniste",
    opener: "Ouvreur",
    ticket_seller: "Vendeur de billets"
  }.freeze

  # Définition de l'enum avec les valeurs numériques
  enum :role, {
    projectionist: 0,
    opener: 1,
    ticket_seller: 2
  }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: [ :programmation_id, :role ], message: "est déjà assigné à ce rôle pour cette programmation" }

  def role_name
    return nil unless role
    ROLES[role.to_sym]
  end

  # Surcharge de la méthode d'attribution du rôle
  def role=(value)
    if value.is_a?(String) && value.match?(/^\d+$/)
      super(value.to_i)
    elsif value.is_a?(String) && ROLES.key?(value.to_sym)
      super(value)
    else
      super(value)
    end
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
