class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer 'order_date', :limit   => 8
      t.integer 'estimated_date', :limit   => 8
      t.integer 'provider_id'
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
