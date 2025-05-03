ActiveAdmin.register ProgrammationStaff do
  belongs_to :programmation
  permit_params :user_id, :role

  form do |f|
    f.inputs do
      f.input :user, collection: User.all
      f.input :role, as: :select, collection: ProgrammationStaff::ROLES.map { |k, v| [ v, k ] }
    end
    f.actions
  end
end
