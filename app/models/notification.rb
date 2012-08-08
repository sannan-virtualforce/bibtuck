# == Schema Information
#
# Table name: notifications
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  body         :text
#  subject_type :string(255)
#  subject_id   :integer
#  viewed_at    :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  actor_type   :string(255)
#  actor_id     :integer
#  origin_type  :string(255)
#  origin_id    :integer
#  template     :string(255)
#

class Notification < ActiveRecord::Base
  #attr_accessible # none

  NOTIFICATION_TEMPLATES = [
    'new_follow',
    'buck_refund_accepted',
    'buck_refund_rejected',
    'new_user',
    'buck_purchase',
    'buck_refund_reminder',
    'new_message',
    'founding_member',
    'invitation',
    'bibbed_item',
    'rating',
    'welcome',
    'tucked_seller',
    'shipped_item',
    'delivered_item',
    'buck_refund_request',
    'credit',
    'first_bib',
    'added_photo'
  ]

  validates_presence_of :user_id,
                        :template
                        #:body

  validates_inclusion_of :template, :in => NOTIFICATION_TEMPLATES

  belongs_to :user

  belongs_to :actor,    :polymorphic => true
  belongs_to :subject,  :polymorphic => true
  belongs_to :origin,   :polymorphic => true

  scope :unread, where(:viewed_at => nil)
  scope :viewed, where(:viewed_at.ne => nil)
  scope :sorted, order('created_at DESC')

  after_save :update_user_unread_notifications_count!

  after_create :send_emails

  def viewed?
    !!viewed_at
  end

  def view!
    touch(:viewed_at)
  end

  def view=(bool)
    view! if bool == 'true'
  end

  def view
    viewed?
  end

  def send_emails
    case template
    when 'new_user' then
      Notifier.welcome_user(user_id).deliver
    when 'new_follow' then
      Notifier.new_follower(origin_id).deliver
    when 'buck_purchase' then
      Notifier.buck_purchase(origin_id).deliver
    when 'new_message' then
      Notifier.new_message(origin_id).deliver
    when 'buck_refund_request'
      Notifier.buck_refund_request(origin_id).deliver
    when 'invitation'
      Notifier.invitation_accepted(origin_id).deliver
    end
  end

private

  def update_user_unread_notifications_count!
    return nil unless user
    user.update_attribute(:unread_notifications_count,
                          user.notifications.unread.count)
  end

end
