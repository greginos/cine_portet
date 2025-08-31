class MakeMovieIdOptionalInProgrammations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :programmations, :movie_id, true
    remove_foreign_key :programmations, :movies rescue nil
    add_foreign_key :programmations, :movies
  end
end
