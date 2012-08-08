class CreateParameters < ActiveRecord::Migration
  def self.up
    create_table :parameters do |t|
      t.string :key
      t.string :description
      t.string :content_type
      t.text :value

      t.timestamps
    end
    add_index :parameters, :key, :unique => true
  end

  def self.down
    drop_table :parameters
  end
end
