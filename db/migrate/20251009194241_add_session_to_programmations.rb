class AddSessionToProgrammations < ActiveRecord::Migration[8.0]
  def change
    add_reference :programmations, :session, foreign_key: true
  end
end