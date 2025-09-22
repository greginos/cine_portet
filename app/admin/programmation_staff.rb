ActiveAdmin.register ProgrammationStaff do
  belongs_to :programmation
  belongs_to :user

  permit_params :user_id, :role

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.where.not(teams: []).map { |u| [ "#{u.first_name} #{u.last_name} - #{u.teams}", u.id ] }
      f.input :role, as: :select, collection: ProgrammationStaff.roles.map { |k, v| [ ProgrammationStaff::ROLES[k.to_sym], v ] }
    end
    f.actions
  end
end
