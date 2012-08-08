class RemoveNaCategory < ActiveRecord::Migration
  def self.up
    Category.where(:name => 'n/a').first.destroy
  end

  def self.down
  end
end
