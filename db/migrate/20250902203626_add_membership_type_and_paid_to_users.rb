class AddMembershipTypeAndPaidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :membership_type, :integer
    add_column :users, :paid, :boolean
  end
end
