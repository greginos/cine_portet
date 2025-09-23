ActiveAdmin.register User, as: "Volunteer" do
  controller do
    def scoped_collection
      super.volunteers
    end
  end

  menu label: "Bénévoles", priority: 2

  # Définir explicitement les filtres autorisés
  filter :first_name, label: "Prénom"
  filter :last_name, label: "Nom"
  filter :email, label: "Email"
  filter :member_number, label: "Numéro de membre"
  filter :membership_type, label: "Type d'adhésion"
  filter :city, label: "Ville"
  filter :teams, as: :string, label: "Équipes"
  filter :created_at, label: "Créé le"

  index title: "Bénévoles" do
    selectable_column
    id_column
    column "Prénom", :first_name
    column "Nom", :last_name
    column "Email", :email
    column "N° membre", :member_number
    column "Équipes", :teams do |user|
      if user.teams.present?
        user.teams.map { |t| I18n.t("teams.#{t}") }.join(", ")
      else
        "Aucune équipe"
      end
    end
    actions
  end
end
