class Discount < ActiveRecord::Base
  has_many :orders

  DISCOUNT_TYPES = [
    'free_shipping',
    'free_transaction',
    'no_fees'
  ]

  validates_inclusion_of :discount_type, :in => DISCOUNT_TYPES
  validate :code, :uniqueness => true

  def free_shipping?
    ['no_fees', 'free_shipping'].member?(discount_type)
  end

  def free_transaction?
    ['no_fees', 'free_transaction'].member?(discount_type)
  end

  def used_count
    orders.count
  end

  def still_valid?
    if total_uses.present? && orders.count >= total_uses
      return false
    else
      return true
    end
  end
end
