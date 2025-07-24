class AddAddressToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :address, :string
    add_column :users, :zip_code, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :phone, :string
    add_column :users, :member_number, :string 
  end
end
