class AddBibHashToPhotos < ActiveRecord::Migration
  def self.up
    add_column(:photos, :bib_hash, :string)
  end

  def self.down
    remove_column(:photos, :bib_hash)
  end
end
