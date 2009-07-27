class CreateSaleLines < ActiveRecord::Migration
  def self.up
    create_table :sale_lines do |t|
      t.integer 'sale_id'
      t.integer 'product_id'
      t.integer 'qty'
      t.integer 'received_qty'
      t.integer 'provided_qty'
      t.timestamps
    end
  end

  def self.down
    drop_table :order_lines
  end
end
