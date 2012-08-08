class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :discount

  has_one :buck_transactions, :as => :reference
  has_many :order_items, :dependent => :destroy
  has_many :items, :through => :order_items

  before_save :set_totals

  validates_presence_of :user
  validates_presence_of :to_addr_first_name, :to_addr_last_name
  validates_presence_of :to_addr_street_line1, :to_addr_city, :to_addr_state, :to_addr_zipcode

  TRANSACTION_FEE_IN_CENTS = 300

  attr_accessor :discount_code
  attr_reader :discount_code_error

  include Orderable

  def to_addr
    address = Address.new
    %w(first_name last_name street_line1 street_line2 city state zipcode phone).each do |attr|
      address[attr] = read_attribute("to_addr_#{attr}")
    end
    return address
  end

  def to_addr=(address)
    %w(id first_name last_name street_line1 street_line2 city state zipcode phone).each do |attr|
      write_attribute "to_addr_#{attr}", address.try(attr)
    end
  end

  def calculate_bucks
    order_items.map(&:item).map(&:price).sum
  end

  def calculate_shipping_cost
    if discount.try(:free_shipping?)
      return 0
    end
    order_items.map(&:item).map(&:shipping_fee_in_cents).sum
  end

  def calculate_transaction_fee
    if discount.try(:free_transaction?)
      return 0
    end
    order_items.map(&:item).map(&:transaction_fee_in_cents).sum
  end

  def total
    amount_in_cents / 100
  end

  def total_bucks
    order_items.map(&:item).map(&:price).sum
  end

  def shipping_cost
    shipping_cost_in_cents / 100
  end

  def transaction_fee
    transaction_fee_in_cents / 100
  end

  def total_fees
    shipping_cost_in_cents + transaction_fee_in_cents
  end

  def set_totals
    self.bucks_total = calculate_bucks
    self.shipping_cost_in_cents = calculate_shipping_cost
    self.transaction_fee_in_cents = calculate_transaction_fee
    self.amount_in_cents = shipping_cost_in_cents + transaction_fee_in_cents
  end

  def after_purchase
    return false if is_complete?

    Notifier.tucked_for_buyer(self).deliver

    Order.transaction do
      set_totals
      order_items.each do |order_item|
        order_item.item.tuck!(self)
        order_item.generate_shipping_label!(false)
        Notifier.tucked_for_seller(order_item).deliver
      end

      if user.invited_by.present? && user.orders.blank?
        BuckTransaction.create(:user => user,
                               :reason => :invitee_tuck,
                               :reference => self,
                               :delta => BuckTransaction::POINTS[:invitee_tuck])
      end

      BuckTransaction.create(:user => user,
                             :reason => :tuck_buyer,
                             :reference => self,
                             :delta => -1 * total_bucks)

      update_attribute(:to_addr_id, nil)
      update_attribute(:is_complete, true)
    end
  end
end
