class CreateSales < ActiveRecord::Migration
  def self.up
    create_table :sales do |t|
      t.integer 'sale_date', :limit   => 8
      t.integer 'estimated_date', :limit   => 8
      t.integer 'user_id'
      t.integer 'client_id'
      t.integer 'sale_state_id'
      t.string  'track1'
      t.timestamps
    end
  end

  def self.down
    drop_table :sales
  end
end
