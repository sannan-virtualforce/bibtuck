class Cart < ActiveRecord::Base

  CLEANUP_TIMEOUT_MIN = 30

  belongs_to :user

  has_many :cart_items, :dependent => :destroy
  has_many :items, :through => :cart_items

  validates :user_id, :presence => true
  validates :user_id, :uniqueness => true

  def add_item(item)
    cart_items.create(:item => item)
  end

  def remove_item(item)
    cart_item = cart_items.find_by_item_id(item.id)
    cart_item.destroy if cart_item
  end

  def clear!
    cart_items.destroy_all
  end

  def filled?
    cart_items.count > 0
  end

  def has_item?(item)
    cart_item = cart_items.find_by_item_id(item.id)
    cart_item != nil
  end

  def self.item_in_any_cart?(item)
    cart_item = CartItem.find_by_item_id(item.id)
    cart_item != nil
  end

  def size
    cart_items.count
  end

  def total_bucks
    items.map(&:price).sum
  end

  def amount_needed(user, item = nil)
    total = total_bucks + (item.try(:price) || 0)
    total - user.buck_balance
  end

end
