class ChangeFollowsDefaults < ActiveRecord::Migration

  def self.up
    change_column :follows, :follower_id, :integer, :null => false
    change_column :follows, :following_id, :integer, :null => false
    add_index :follows, [:follower_id, :following_id]
  end

  def self.down
    change_column :follows, :follower_id, :integer, :null => true
    change_column :follows, :following_id, :integer, :null => true
    remove_index :follows, [:follower_id, :following_id]
  end

end
