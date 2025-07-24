class ChangeUserColumn < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :family_name, :last_name
  end
end
