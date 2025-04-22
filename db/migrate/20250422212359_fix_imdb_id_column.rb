class FixImdbIdColumn < ActiveRecord::Migration[8.0]
  def change
    remove_column :programmations, :tmdb_id
    add_column :programmations, :imdb_id, :string
    add_index :programmations, :imdb_id
  end
end
