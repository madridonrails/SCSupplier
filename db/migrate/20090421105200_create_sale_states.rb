class CreateSaleStates < ActiveRecord::Migration
  def self.up
    create_table :sale_states do |t|
      t.string  'name'
      t.timestamps
    end
  end

  def self.down
    drop_table :sale_states
  end
end
