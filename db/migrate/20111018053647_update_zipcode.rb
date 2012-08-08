class UpdateZipcode < ActiveRecord::Migration
  def self.up
    change_column(:addresses, :zipcode, :string)
  end

  def self.down
    change_column(:addresses, :zipcode, :integer)
  end
end
