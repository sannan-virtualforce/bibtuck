class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.string :box_type
      t.timestamps
    end

    rename_column(:items, :category, :category_id)

    Category.create!(:name => 'dresses', :box_type => 'a')
    Category.create!(:name => 'accessories', :box_type => 'a')
    Category.create!(:name => 'bags', :box_type => 'b')
    Category.create!(:name => 'tops', :box_type => 'a')
    Category.create!(:name => 'sweaters', :box_type => 'b')
    Category.create!(:name => 'coats + jackets', :box_type => 'b')
    Category.create!(:name => 'pants', :box_type => 'a')
    Category.create!(:name => 'skirts', :box_type => 'a')
    Category.create!(:name => 'shoes', :box_type => 'b')
    Category.create!(:name => 'jumpsuits/rompers', :box_type => 'a')
    Category.create!(:name => 'n/a', :box_type => 'a')

    Item.all.map { |i| i.update_attribute(:category_id, Category.other.id) }
  end

  def self.down
    rename_column(:items, :category_id, :category)
    drop_table :categories
  end
end
