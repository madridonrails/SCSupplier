class CreateRawProductTranslations < ActiveRecord::Migration
  def self.up
    create_table :raw_product_translations do |t|
      t.integer 'raw_product_id'
      t.integer 'locale_id'
      t.string 'name'
      t.text 'description'
      t.timestamps
    end
  end

  def self.down
    drop_table :raw_product_translations
  end
end
