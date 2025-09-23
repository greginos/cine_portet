ActiveAdmin.register ProgrammationStaff do
  belongs_to :programmation
  belongs_to :user

  permit_params :user_id, :role

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.volunteers.map { |u| [ "#{u.first_name} #{u.last_name} - #{u.teams}", u.id ] }
      f.input :role, as: :select, collection: ProgrammationStaff.roles.keys.map { |k| I18n.t("programmation_staff.roles.#{k}") }
    end
    f.actions
  end
end
