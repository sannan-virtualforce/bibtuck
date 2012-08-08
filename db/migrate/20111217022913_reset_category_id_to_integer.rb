class ResetCategoryIdToInteger < ActiveRecord::Migration
  def self.up
    remove_column(:items, :category_id)
    add_column(:items, :category_id, :integer)

    Item.all.map { |x| x.update_attribute(:category_id, Category.first.id) }
  end

  def self.down
    remove_column(:items, :category_id)
    add_column(:items, :category_id, :string)
  end
end
