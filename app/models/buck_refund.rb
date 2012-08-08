# == Schema Information
#
# Table name: buck_refunds
#
#  id             :integer         not null, primary key
#  item_id        :integer
#  user_id        :integer
#  comment        :text
#  outcome_cd     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  seller_comment :text
#

class BuckRefund < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  scope :pending, where(:outcome => nil)

  as_enum :outcome, {
    :accepted => 1,
    :rejected => 0,
  }

  REASONS = [
    'looks different to image on site',
    'poor quality/faulty',
    'doesn\'t fit properly',
    'incorrect item received',
    'item did not arrive',
    'arrived too late',
  ]

  after_create do
    Notification.create!(
      :template => 'buck_refund_request',
      :user     => item.user,
      :subject  => self,
      :actor    => user,
      :origin   => self
    )
  end

  after_update do |buck_refund|
    case outcome
    when :accepted
      accept!
    when :rejected
      reject!
    end
  end

  def accept!
    self.class.transaction do
      BuckTransaction.create(:user => item.user,
                             :reference => self,
                             :reason => :buck_refund_seller,
                             :delta => -1 * item.price)

      BuckTransaction.create(:user => user,
                             :reason => :buck_refund_buyer,
                             :reference => self,
                             :delta => item.price)

      Notification.create!(
        :template => 'buck_refund_accepted',
        :user     => user,
        :subject  => self,
        :actor    => user,
        :origin   => self
      )

      create_message_from_seller_comment
    end
  end

  def reject!
    self.class.transaction do
      Notification.create!(
        :template => 'buck_refund_rejected',
        :user     => user,
        :subject  => self,
        :actor    => user,
        :origin   => self
      )

      Notifier.buck_refund_rejected(self).deliver!
      create_message_from_seller_comment
    end
  end

  def create_message_from_seller_comment
    convo = item.user.convo_with(user)

    if convo.nil?
      convo = item.user.user_conversations.build
      convo.build_conversation.messages.build
      convo.save!
    end

    convo.conversation.messages.create!({
      :user => user,
      :body => seller_comment
    })
  end
end
