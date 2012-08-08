class AddSavedPhotos < ActiveRecord::Migration
  def self.up
    create_table :saved_photos do |t|
      t.string :path
      t.references :user
      t.references :item
      t.timestamps
    end
  end

  def self.down
    drop_table :saved_photos
  end
end
