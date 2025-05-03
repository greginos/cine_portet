class RemoveDateFromProgrammations < ActiveRecord::Migration[8.0]
  def change
    remove_column :programmations, :date, :date
  end
end
