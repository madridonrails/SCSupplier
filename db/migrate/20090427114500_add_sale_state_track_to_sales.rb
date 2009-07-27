class AddSaleStateTrackToSales < ActiveRecord::Migration

  def self.up
    add_column :sales, :state, :string
    add_column :sales, :track, :string
  end

  def self.down
    remove_column :sales, :state
    remove_column :sales, :track
  end
end
