class AddInviteNameToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :invite_name, :string)
  end

  def self.down
    remove_column(:users, :invite_name)
  end
end
