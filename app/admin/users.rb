ActiveAdmin.register User do
  menu priority: 2

  permit_params :first_name, :last_name, :email, :password, :password_confirmation,
                :phone, :address, :zip_code, :city, :membership_type, :paid, teams: []

  before_save do |user|
    user.teams = user.teams.reject(&:blank?) if user.teams.present?
  end

  # === INDEX ===
  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone
    column("Adhésion") { |u| u.membership_type&.humanize }
    column :paid
    column :created_at
    actions
    column :teams do |user|
      if user.teams.present?
        user.teams.map { |t| I18n.t("teams.#{t}") }.join(", ")
      else
        "Aucune"
      end
    end
  end

  # === FILTRES ===
  filter :first_name
  filter :last_name
  filter :membership_type, as: :select, collection: User.membership_types.keys.map { |k| [ I18n.t("activerecord.attributes.user.membership_types.#{k}"), k ] }
  filter :paid
  filter :created_at

  # === FORMULAIRE ===
  form do |f|
    f.inputs "Informations de l'utilisateur" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone
      f.input :address
      f.input :zip_code
      f.input :city
      f.input :member_number
      f.input :membership_type, as: :select, collection: User.membership_types.keys.map { |k| [ I18n.t("activerecord.attributes.user.membership_types.#{k}"), k ] }
      f.input :paid, as: :boolean, label: "Cotisation payée ?"
      f.input :teams, 
              as: :check_boxes,
              collection: User::TEAMS.map { |team| [I18n.t("teams.#{team}"), team] },
              label: "Équipes"
    end
    f.actions
  end

  # === SHOW ===
  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :phone
      row :address
      row :zip_code
      row :city
      row :member_number
      row("Adhésion") { |u| u.membership_type&.humanize }
      row("Cotisation payée ?") do |u|
        content_tag :span, (u.paid ? "Oui" : "Non"), 
                    class: "status #{u.paid ? 'paid' : 'unpaid'}"
      end
      row :teams do |user|
        if user.teams.present?
          user.teams.map { |t| I18n.t("teams.#{t.to_s}") }.join(", ")
        else
          "Aucune équipe"
        end
      end
      row :created_at
      row :updated_at   
    end 
  end
end
