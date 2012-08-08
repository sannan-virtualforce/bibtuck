class AddJeansCategory < ActiveRecord::Migration
  def self.up
    Category.create!(:name => 'jeans', :box_type => 'a')
  end

  def self.down
    Category.where(:name => 'jeans').destroy
  end
end
