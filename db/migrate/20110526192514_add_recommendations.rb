class AddRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.integer :item_id, :null => false
      t.integer :recommended_item_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
