class CreateRegistrationCodes < ActiveRecord::Migration
  def self.up
    create_table :registration_codes do |t|
      t.string :registration_code

      t.timestamps
    end
  end

  def self.down
    drop_table :registration_codes
  end
end
