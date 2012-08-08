class AddSocialMediaLinksToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :blog_url, :string
    add_column :users, :twitter_username, :string
    add_column :users, :facebook_page, :string
  end

  def self.down
    remove_column :users, :facebook_page
    remove_column :users, :twitter_username
    remove_column :users, :blog_url
  end
end
