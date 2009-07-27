class CreateOrderStates < ActiveRecord::Migration
  def self.up
    create_table :order_states do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :order_states
  end
end
