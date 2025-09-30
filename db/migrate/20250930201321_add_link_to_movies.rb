class AddLinkToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :url, :string  
  end
end
