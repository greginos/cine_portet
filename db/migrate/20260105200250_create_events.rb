class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :start_time, null: false
      t.references :programmation, foreign_key: true, null: true
      t.references :session, foreign_key: true, null: true

      t.timestamps
    end
    
    add_index :events, :start_time
    add_index :events, [:session_id, :start_time]
  end
end