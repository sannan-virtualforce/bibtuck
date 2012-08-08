class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credits do |t|
      t.references :user
      t.integer :bucks, :null => false
      t.string :memo
      t.timestamps
    end
  end

  def self.down
    drop_table :credits
  end
end
