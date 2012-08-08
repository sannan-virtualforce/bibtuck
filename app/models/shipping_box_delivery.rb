class ShippingBoxDelivery < ActiveRecord::Base
  belongs_to :user
  belongs_to :address

  validates :user, :presence => true
  validates :box_size, :presence => true
end
