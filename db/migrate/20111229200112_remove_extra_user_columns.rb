class RemoveExtraUserColumns < ActiveRecord::Migration
  def self.up
    remove_column(:users, :location)
    remove_column(:users, :city)
  end

  def self.down
    add_column(:users, :city, :string)
    add_column(:users, :location, :string)
  end
end
