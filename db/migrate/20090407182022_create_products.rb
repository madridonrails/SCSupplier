class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string 'reference'
      t.string 'name'
      t.string 'description'
      t.integer 'stock'
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
