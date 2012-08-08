class RenameSkirtsCategory < ActiveRecord::Migration
  def self.up
    Category.update_all({:name => 'skirts/shorts'}, {:name => 'skirts'})
  end

  def self.down
    Category.update_all({:name => 'skirts'}, {:name => 'skirts/shorts'})
  end
end
