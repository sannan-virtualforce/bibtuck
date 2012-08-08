class AddActivelyFeaturedToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :currently_featured, :boolean)
  end

  def self.down
    remove_column(:users, :currently_featured)
  end
end
