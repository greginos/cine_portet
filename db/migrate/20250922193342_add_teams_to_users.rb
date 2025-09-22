class AddTeamsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :teams, :text
  end
end
