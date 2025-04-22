class AddTmdbIdToProgrammations < ActiveRecord::Migration[8.0]
  def change
    add_column :programmations, :tmdb_id, :integer
    add_index :programmations, :tmdb_id
  end
end
