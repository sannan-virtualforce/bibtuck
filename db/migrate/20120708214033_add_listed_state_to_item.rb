class AddListedStateToItem < ActiveRecord::Migration
  def self.up
    Item.where(:state => :open).each do |item|
      if item.bibbed_at
        item.update_attribute :state, :listed
      end
    end
  end

  def self.down
    Item.update_all({:state => :open}, {:state => :listed})
  end
end
