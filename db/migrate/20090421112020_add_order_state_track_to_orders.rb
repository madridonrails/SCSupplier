class AddOrderStateTrackToOrders < ActiveRecord::Migration

  def self.up
    add_column :orders, :state, :string
    add_column :orders, :track, :string
  end

  def self.down
    remove_column :orders, :state
    remove_column :orders, :track
  end
end
