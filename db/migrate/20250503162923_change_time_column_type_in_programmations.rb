class ChangeTimeColumnTypeInProgrammations < ActiveRecord::Migration[8.0]
  def up
    # On ajoute une nouvelle colonne datetime
    add_column :programmations, :datetime, :datetime

    # On copie les données de time vers datetime en utilisant la date du jour
    execute <<-SQL
      UPDATE programmations#{' '}
      SET datetime = (CURRENT_DATE + time)::timestamp;
    SQL

    # On supprime l'ancienne colonne time
    remove_column :programmations, :time

    # On renomme la nouvelle colonne en time
    rename_column :programmations, :datetime, :time
  end

  def down
    # On ajoute une nouvelle colonne time
    add_column :programmations, :time_only, :time

    # On copie les données de time vers time_only
    execute <<-SQL
      UPDATE programmations#{' '}
      SET time_only = time::time;
    SQL

    # On supprime l'ancienne colonne time
    remove_column :programmations, :time

    # On renomme la nouvelle colonne en time
    rename_column :programmations, :time_only, :time
  end
end
