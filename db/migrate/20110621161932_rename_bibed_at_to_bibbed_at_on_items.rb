class RenameBibedAtToBibbedAtOnItems < ActiveRecord::Migration
  def self.up
    rename_column :items, :bibed_at, :bibbed_at
  end

  def self.down
    rename_column :items, :bibbed_at, :bibed_at
  end
end
