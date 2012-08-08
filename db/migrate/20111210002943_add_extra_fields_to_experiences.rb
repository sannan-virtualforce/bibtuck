class AddExtraFieldsToExperiences < ActiveRecord::Migration
  def self.up
    add_column(:experiences, :item_id, :integer)
  end

  def self.down
    remove_column(:experiences, :item_id)
  end
end
