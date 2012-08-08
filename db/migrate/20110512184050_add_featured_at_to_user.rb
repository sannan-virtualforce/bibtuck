class AddFeaturedAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :featured_at, :datetime
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :username, :string
    add_column :users, :birthday, :date
    add_column :users, :location, :string
    add_column :users, :occupation, :string
    add_column :users, :city, :string
    add_column :users, :about_me, :text
    add_column :users, :website_url, :string
    add_column :users, :profile_picture, :string
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :username
    remove_column :users, :birthday
    remove_column :users, :location
    remove_column :users, :occupation
    remove_column :users, :city
    remove_column :users, :about_me
    remove_column :users, :website_url
    remove_column :users, :profile_picture
    remove_column :users, :featured_at
  end
end
