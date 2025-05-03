class RemoveMovieFieldsFromProgrammations < ActiveRecord::Migration[8.0]
  def change
    remove_column :programmations, :title, :string
    remove_column :programmations, :description, :text
    remove_column :programmations, :duration, :integer
    remove_column :programmations, :genre, :string
    remove_column :programmations, :director, :jsonb
    remove_column :programmations, :cast, :jsonb
    remove_column :programmations, :poster_url, :string
  end
end
