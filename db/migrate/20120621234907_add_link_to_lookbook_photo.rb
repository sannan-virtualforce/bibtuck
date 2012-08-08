class AddLinkToLookbookPhoto < ActiveRecord::Migration
  def self.up
    add_column :lookbook_photos, :link, :string
  end

  def self.down
    remove_column :lookbook_photos, :link
  end
end
