class UpdateBuckRefunds < ActiveRecord::Migration
  def self.up
    remove_column(:buck_refunds, :reason)
    add_column(:buck_refunds, :seller_comment, :text)
  end

  def self.down
    remove_column(:buck_refunds, :seller_comment)
    add_column(:buck_refunds, :reason, :string)
  end
end
