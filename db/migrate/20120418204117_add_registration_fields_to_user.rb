class AddRegistrationFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :current_city, :string)
    add_column(:users, :tos_agreed_at, :datetime)
  end

  def self.down
    remove_column(:users, :tos_agreed_at)
    remove_column(:users, :current_city)
  end
end
