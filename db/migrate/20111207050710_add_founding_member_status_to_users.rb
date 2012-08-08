class AddFoundingMemberStatusToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :founding_member_at, :datetime)
  end

  def self.down
    remove_column(:users, :founding_member_at)
  end
end
