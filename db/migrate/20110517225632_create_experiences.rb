class CreateExperiences < ActiveRecord::Migration
  def self.up
    create_table :experiences do |t|
      t.text :comment
      t.integer :rating
      t.references :user
      t.integer :rater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :experiences
  end
end
