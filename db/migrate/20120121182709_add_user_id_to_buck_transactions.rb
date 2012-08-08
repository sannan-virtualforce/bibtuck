class AddUserIdToBuckTransactions < ActiveRecord::Migration
  def self.up
    add_column(:buck_transactions, :user_id, :integer)
  end

  def self.down
    remove_column(:buck_transactions, :user_id)
  end
end
