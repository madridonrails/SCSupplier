class CreateAssemblies < ActiveRecord::Migration
  def self.up
    create_table :assemblies do |t|
      t.integer 'raw_product_id'
      t.integer 'product_id'
      t.integer 'quantity'
      t.timestamps
    end
  end

  def self.down
    drop_table :assemblies
  end
end
