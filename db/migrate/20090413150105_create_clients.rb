class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string 'client_name'
      t.string 'name'
      t.string 'surname'
      t.string 'email'
      t.integer 'phone'
      t.string 'address'
      t.string 'city'
      t.string 'country'
      t.integer 'postal_code'
      t.integer 'mobile'
      t.integer 'fax'

      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end
