class AddRegistrationLimitToRegistrationCodes < ActiveRecord::Migration
  def self.up
    add_column(:registration_codes, :registration_limit, :integer)
    rename_column(:registration_codes, :registration_code, :code)
  end

  def self.down
    rename_column(:registration_codes, :code, :registration_code)
    remove_column(:registration_codes, :registration_limit)
  end
end
