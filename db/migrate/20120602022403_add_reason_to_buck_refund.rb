class AddReasonToBuckRefund < ActiveRecord::Migration
  def self.up
    add_column(:buck_refunds, :reason, :string)
  end

  def self.down
    remove_column(:buck_refunds, :reason)
  end
end
