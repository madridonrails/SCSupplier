class CreateOrderLines < ActiveRecord::Migration
  def self.up
    create_table :order_lines do |t|
      t.integer 'order_id'
      t.integer 'raw_product_id'
      t.integer 'qty'
      t.integer 'received_qty'
      t.timestamps
    end
  end

  def self.down
    drop_table :order_lines
  end
end
