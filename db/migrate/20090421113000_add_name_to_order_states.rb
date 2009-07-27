class AddNameToOrderStates < ActiveRecord::Migration
  
  def self.up
    add_column :order_states, :name, :string
  end

  def self.down
    remove_column :order_states, :name
  end
end
