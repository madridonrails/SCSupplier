class CreateProductTranslations < ActiveRecord::Migration
  def self.up
    create_table :product_translations do |t|
      t.integer 'product_id'
      t.integer 'locale_id'
      t.string 'name'
      t.text 'description'
      t.timestamps
    end
  end

  def self.down
    drop_table :product_translations
  end
end
