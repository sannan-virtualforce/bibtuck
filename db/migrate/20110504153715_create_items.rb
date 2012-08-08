class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :name
      t.string :category
      t.string :condition
      t.string :size
      t.references :brand
      t.references :user
      t.string :fit
      t.string :color
      t.text :description
      t.text :why_sell
      t.float :price
      t.datetime :bibed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
