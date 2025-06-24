class ChangeRoleToIntegerInProgrammationStaffs < ActiveRecord::Migration[8.0]
  def up
    # Supprimer l'index unique s'il existe
    begin
      remove_index :programmation_staffs, name: 'index_programmation_staff_unique'
    rescue
      # L'index n'existe pas, on continue
    end

    # Supprimer l'ancienne colonne role
    remove_column :programmation_staffs, :role rescue nil

    # Ajouter la nouvelle colonne role en integer
    add_column :programmation_staffs, :role, :integer

    # Recréer l'index unique
    add_index :programmation_staffs, [ :programmation_id, :user_id, :role ], unique: true, name: 'index_programmation_staff_unique'
  end

  def down
    # Supprimer l'index unique s'il existe
    begin
      remove_index :programmation_staffs, name: 'index_programmation_staff_unique'
    rescue
      # L'index n'existe pas, on continue
    end

    # Supprimer la colonne role
    remove_column :programmation_staffs, :role rescue nil

    # Ajouter la colonne role en string
    add_column :programmation_staffs, :role, :string

    # Recréer l'index unique
    add_index :programmation_staffs, [ :programmation_id, :user_id, :role ], unique: true, name: 'index_programmation_staff_unique'
  end
end
