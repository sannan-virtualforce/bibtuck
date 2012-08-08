class AddTopRatedToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :top_rated_at, :datetime)
  end

  def self.down
    remove_column(:users, :top_rated_at)
  end
end
