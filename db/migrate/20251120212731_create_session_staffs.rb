class CreateSessionStaffs < ActiveRecord::Migration[7.0]
  def change
    create_table :session_staffs do |t|
      t.references :session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :position, default: 0, null: false  # 0: start, 1: end

      t.timestamps
    end

    add_index :session_staffs, [ :session_id, :user_id, :position ], unique: true
  end
end
