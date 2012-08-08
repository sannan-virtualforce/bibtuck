# == Schema Information
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  box_type   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base

  # For use with Endicia shipping.
  # Prices are in cents.
  #
  BOX_SIZES_PRICES = {
    'a' => '600',
    'b' => '1100'
  }

  BOX_SIZES_ENDICIA = {
    'a' => 'RegionalRateBoxA',
    'b' => 'RegionalRateBoxB'
  }

  default_scope order('name asc')
  has_many :items
  validates_presence_of :box_type, :name

  def self.shipping_box_sizes
    BOX_SIZES_PRICES.keys
  end

  def self.box_type_lookup
    Category.all.inject({}) { |hsh, c| hsh[c.id] = c.box_type; hsh }
  end

  def shipping_fee
    BOX_SIZES_PRICES[box_type].to_i
  end

  def sizes
    CategorySize.get(self)
  end
end
