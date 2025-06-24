ActiveAdmin.register User do
  menu priority: 2

  permit_params :first_name, :family_name, :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :first_name
    column :family_name
    column :email
    column :created_at
    actions
  end

  filter :first_name
  filter :family_name
  filter :email
  filter :created_at

  form do |f|
    f.inputs "Informations de l'utilisateur" do
      f.input :first_name
      f.input :family_name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  show do
    attributes_table do
      row :first_name
      row :family_name
      row :email
      row :created_at
      row :updated_at
    end

    panel "Programmations" do
      table_for user.staffed_programmations do
        column :movie
        column :time
        column :role do |programmation|
          programmation.programmation_staffs.find_by(user: user).role_name
        end
      end
    end

    action_item :send_magic_link do
      link_to "Envoyer le lien de connexion", send_magic_link_admin_user_path(resource), method: :post
    end
  end

  member_action :send_magic_link, method: :post do
    token = resource.generate_sign_in_token!
    MagicLinkMailer.sign_in_email(resource, token).deliver_later
    redirect_to admin_user_path(resource), notice: "Le lien de connexion a été envoyé à #{resource.email}"
  end

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      super
    end
  end
end
