class CreateLocales < ActiveRecord::Migration
  def self.up
    create_table :locales do |t| 
      t.string :code, :null=>false, :limit=>5
      t.string :name

      t.timestamps
    end 

    add_column :users, :locale_id, :integer
  end

  def self.down
    remove_column :users, :locale_id
    drop_table :locales
  end
end
