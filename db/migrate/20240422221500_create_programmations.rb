class CreateProgrammations < ActiveRecord::Migration[8.0]
  def change
    create_table :programmations do |t|
      t.string :title
      t.text :description
      t.date :date
      t.time :time
      t.string :poster_url
      t.string :genre
      t.integer :duration
      t.jsonb :director, default: {}
      t.jsonb :actors, default: {}
      t.string :imdb_id
      t.index :imdb_id

      t.timestamps
    end
  end
end
