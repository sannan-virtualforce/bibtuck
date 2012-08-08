# == Schema Information
# Schema version: 20120117211534
#
# Table name: buck_purchases
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  first_name       :string(255)
#  last_name        :string(255)
#  bucks            :integer         not null
#  amount_in_cents  :integer         not null
#  express_token    :string(255)
#  express_payer_id :string(255)
#  response         :text
#  ip_address       :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

# Represents a transaction having to do with money.
#
class BuckPurchase < ActiveRecord::Base
  belongs_to :user
  has_one :buck_transaction, :as => :reference

  validates_numericality_of :amount_in_cents
  validates_presence_of :user
  after_initialize :convert_bucks_to_cents

  include Orderable

  # number of bucks => cents
  PRESET_BUCK_PURCHASES = {
    20  => 2000,
    50  => 5000,
    100 => 10000,
    200 => 20000,
  }

  def self.bucks_to_cents(bucks)
    bucks.to_f * 100
  end

  def price
    amount_in_cents.to_f / 100
  end

  def after_purchase
    BuckTransaction.create!(:reference => self,
                            :user => user,
                            :reason =>  :buck_purchase,
                            :delta => bucks)
  end

  def convert_bucks_to_cents
    self.amount_in_cents = BuckPurchase.bucks_to_cents(bucks.to_i)
  end

  def new_purchase_subject
    ["You purchased", bucks.to_s, "bucks"].join(' ')
  end

end
