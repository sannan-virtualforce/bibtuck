# == Schema Information
# Schema version: 20120203190133
#
# Table name: buck_transactions
#
#  id             :integer         not null, primary key
#  reference_id   :integer
#  reference_type :string(255)
#  delta          :integer
#  created_at     :datetime
#  updated_at     :datetime
#  reason         :string(255)
#  user_id        :integer
#

class BuckTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :reference, :polymorphic => true

  REASONS = [
    :reason,
    :buck_purchase,
    :buck_refund_seller,
    :buck_refund_buyer,
    :tuck_buyer,
    :invitee_tuck,
    :tuck_seller,
    :new_user,
    :invitation,
    :first_bib,
    :credit
  ]

  POINTS = {
    :invitation => 25,
    :new_user => 50,
    :invitee_tuck => 25,
  }

  scope :positive, where('delta > 0')
  scope :negative, where('delta < 0')

  validates_presence_of :reason
  validates_numericality_of :delta
  validates_inclusion_of :reason, :in => REASONS
end
