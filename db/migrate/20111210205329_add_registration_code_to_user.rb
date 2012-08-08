class AddRegistrationCodeToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :registration_code_id, :integer)
  end

  def self.down
    remove_column(:users, :registration_code_id)
  end
end
