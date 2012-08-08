class RemoveBlogUrlFromUsers < ActiveRecord::Migration
  def self.up
    remove_column(:users, :blog_url)
  end

  def self.down
    add_column(:users, :blog_url, :string)
  end
end
