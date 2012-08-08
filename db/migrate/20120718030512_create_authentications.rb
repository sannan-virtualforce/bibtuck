class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.string :name
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
    add_index :authentications, [:provider, :uid], :unique => true
  end

  def self.down
    drop_table :authentications
  end
end
