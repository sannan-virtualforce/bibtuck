class AddDeactivationReasonToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :deactivation_reason, :string
  end

  def self.down
    remove_column :users, :deactivation_reason
  end
end
