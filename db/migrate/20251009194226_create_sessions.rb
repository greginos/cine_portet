class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.text :description

      t.timestamps
    end
  end
end
