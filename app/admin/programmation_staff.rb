ActiveAdmin.register ProgrammationStaff do
  belongs_to :programmation
  permit_params :user_id, :role

  form do |f|
    f.inputs do
      f.input :user, collection: User.all, as: :select, collection: User.all.map { |u| [ "#{u.first_name} #{u.family_name}", u.id ] }
      f.input :role, as: :select, collection: ProgrammationStaff.roles.map { |k, v| [ ProgrammationStaff::ROLES[k.to_sym], v ] }
    end
    f.actions
  end
end
