class AddHideAgeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hide_age, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :hide_age
  end
end
