class CreateProgrammationStaff < ActiveRecord::Migration[8.0]
  def change
    create_table :programmation_staffs do |t|
      t.references :programmation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false

      t.timestamps
    end

    add_index :programmation_staffs, [ :programmation_id, :user_id, :role ], unique: true, name: 'index_programmation_staff_unique'
  end
end
