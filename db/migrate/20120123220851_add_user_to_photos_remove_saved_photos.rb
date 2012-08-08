class AddUserToPhotosRemoveSavedPhotos < ActiveRecord::Migration
  def self.up
    add_column(:photos, :user_id, :integer)
    drop_table(:saved_photos)
  end

  def self.down
    create_table :saved_photos do |t|
      t.string :path
      t.references :user
      t.references :item
      t.timestamps
    end
    remove_column(:photos, :user_id)
  end
end
