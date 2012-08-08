# == Schema Information
#
# Table name: recommendations
#
#  id                  :integer         not null, primary key
#  item_id             :integer         not null
#  recommended_item_id :integer         not null
#  created_at          :datetime
#  updated_at          :datetime
#

class Recommendation < ActiveRecord::Base
  belongs_to :item
  belongs_to :recommended_item, :class_name => 'Item'

  delegate :name, :to         => :item,
                  :prefix     => true,
                  :allow_nil  => true

  delegate :name, :to         => :recommended_item,
                  :prefix     => true,
                  :allow_nil  => true
end
