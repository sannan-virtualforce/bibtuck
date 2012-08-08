class AddMinAmountToDiscount < ActiveRecord::Migration
  def self.up
    add_column :discounts, :min_amount, :integer
  end

  def self.down
    remove_column :discounts, :min_amount
  end
end
