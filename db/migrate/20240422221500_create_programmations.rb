class CreateProgrammations < ActiveRecord::Migration[8.0]
  def change
    create_table :programmations do |t|
      t.string :titre
      t.text :description
      t.date :date
      t.time :heure
      t.string :affiche_url
      t.string :genre
      t.integer :duree
      t.string :realisateur
      t.string :acteurs

      t.timestamps
    end
  end
end
