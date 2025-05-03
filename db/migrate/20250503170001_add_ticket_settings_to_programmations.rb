class AddTicketSettingsToProgrammations < ActiveRecord::Migration[8.0]
  def change
    add_column :programmations, :max_tickets, :integer
    add_column :programmations, :normal_price, :decimal, precision: 8, scale: 2
    add_column :programmations, :member_price, :decimal, precision: 8, scale: 2
    add_column :programmations, :reduced_price, :decimal, precision: 8, scale: 2
  end
end
