class AddExperienceResponses < ActiveRecord::Migration
  def self.up
    add_column(:experiences, :response_1, :string)
    add_column(:experiences, :response_2, :string)
    add_column(:experiences, :response_3, :string)
  end

  def self.down
    remove_column(:experiences, :response_3)
    remove_column(:experiences, :response_2)
    remove_column(:experiences, :response_1)
  end
end
