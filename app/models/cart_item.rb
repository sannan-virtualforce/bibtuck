class CartItem < ActiveRecord::Base

  belongs_to :cart
  belongs_to :item

  validates :cart_id, :item_id, :presence => true
  validates :item_id, :uniqueness => true

end
