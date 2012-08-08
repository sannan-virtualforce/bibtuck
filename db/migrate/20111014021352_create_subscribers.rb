class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, :null => false
      t.string :url
      t.string :occupation
      t.string :favorite_period

      t.timestamps
    end
    add_index :subscribers, :email, :unique => true
  end

  def self.down
    drop_table :subscribers
  end
end
