class RenameImdbIdInProgrammations < ActiveRecord::Migration[8.0]
  def change
    rename_column :programmations, :tmdb_id, :imdb_id
  end
end
