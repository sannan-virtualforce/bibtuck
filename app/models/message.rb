# == Schema Information
#
# Table name: messages
#
#  id                  :integer         not null, primary key
#  sender_id           :integer         not null
#  sender_type         :string(255)     not null
#  body                :text
#  state               :string(255)     not null
#  hidden_at           :datetime
#  type                :string(255)
#  original_message_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#  spam                :boolean         default(FALSE), not null
#

class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation

  has_many  :notifications_as_subject,
            :class_name   => 'Notification',
            :foreign_key  => :subject_id,
            :conditions   => { :origin_type => 'Message' },
            :dependent    => :destroy

  after_create :update_thread, :notify_recepient

  def recipient
    conversation.users.select { |u| u != user }.first
  end

  def new_message_subject
    [ message.sender.display_name,
      "sent you a message"].join(' ')
  end

private

  def update_thread
    conversation.user_conversations.where(:user_id => recipient).each do |uc|
      uc.update_attributes :deleted => nil, :read => nil
    end
  end

  def notify_recepient
    Notification.create(:template => 'new_message', :user => recipient, :subject => self,
      :actor => user, :origin => self)
  end
end
