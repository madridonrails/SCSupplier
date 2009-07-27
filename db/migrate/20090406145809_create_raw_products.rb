class CreateRawProducts < ActiveRecord::Migration
  def self.up
    create_table :raw_products do |t|
      t.string 'name'
      t.text 'description'
      t.integer 'provider_id'
      t.timestamps
    end
  end

  def self.down
    drop_table :raw_products
  end
end
