class AddLookbookPhotos < ActiveRecord::Migration
  def self.up
    create_table :lookbook_photos do |t|
      t.string :path
      t.timestamps
    end
  end

  def self.down
    drop_table :lookbook_photos
  end
end
