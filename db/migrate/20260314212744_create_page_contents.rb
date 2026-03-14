class CreatePageContents < ActiveRecord::Migration[8.0]
  def change
    create_table :page_contents do |t|
      t.string :key, null: false
      t.text :value
      t.string :label
      t.timestamps
    end

    add_index :page_contents, :key, unique: true
  end
end
