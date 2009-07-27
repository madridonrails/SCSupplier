class AddStockPendingToRawProducts < ActiveRecord::Migration
  
  def self.up
    add_column :raw_products, :stock, :integer, :default => 0
    add_column :raw_products, :pending, :integer, :default => 0
  end

  def self.down
    remove_column :raw_products, :stock
    remove_column :raw_products, :pending
  end
end
