class AddReasonToBuckTransactions < ActiveRecord::Migration
  def self.up
    add_column(:buck_transactions, :reason, :string)
  end

  def self.down
    remove_column(:buck_transactions, :reason)
  end
end
