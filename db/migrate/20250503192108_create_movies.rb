class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :description
      t.integer :duration
      t.string :genre
      t.jsonb :director
      t.jsonb :cast
      t.string :poster_url

      t.timestamps
    end
  end
end
