class AddAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :first_name
      t.string :last_name
      t.string :street_line1
      t.string :street_line2
      t.string :city
      t.string :state
      t.integer :zipcode
      t.string :phone
    end
  end

  def self.down
    drop_table :addresses
  end
end
