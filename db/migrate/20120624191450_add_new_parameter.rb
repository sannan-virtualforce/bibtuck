class AddNewParameter < ActiveRecord::Migration
  def self.up
    promotional_message = Parameter.new
    promotional_message.key = :promotional_message
    promotional_message.content_type = 'html'
    promotional_message.description = 'Promotional Message that is shown on every page if specified.'
    promotional_message.save!
  end

  def self.down
    Parameter.destroy_all(:key => :promotional_message)
  end
end
