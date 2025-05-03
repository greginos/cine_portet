class User < ApplicationRecord
  has_many :programmation_staff
  has_many :staffed_programmations, through: :programmation_staff, source: :programmation

  def staffed_programmations_by_role(role)
    staffed_programmations.where(programmation_staff: { role: role })
  end
end
