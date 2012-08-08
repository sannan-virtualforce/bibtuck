class AddIsPrimaryToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :is_primary, :boolean
    Item.all.each do |item|
      primary = item.photos.order(:id).first
      primary.update_attribute(:is_primary, true) if primary
    end
  end

  def self.down
    remove_column :photos, :is_primary
  end
end
