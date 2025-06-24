class AddSignInTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :sign_in_token, :string
    add_column :users, :token_expires_at, :datetime
  end
end
