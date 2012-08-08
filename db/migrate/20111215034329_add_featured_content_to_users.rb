class AddFeaturedContentToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :featured_content, :text)
  end

  def self.down
    remove_column(:users, :featured_content)
  end
end
