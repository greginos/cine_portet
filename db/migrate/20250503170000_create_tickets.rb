class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.references :programmation, null: false, foreign_key: true
      t.string :ticket_type, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.integer :quantity, null: false, default: 1
      t.string :status, null: false, default: 'pending'
      t.string :stripe_session_id
      t.string :email
      t.string :name

      t.timestamps
    end

    add_index :tickets, :ticket_type
    add_index :tickets, :status
  end
end
