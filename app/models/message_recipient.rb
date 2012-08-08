# == Schema Information
#
# Table name: message_recipients
#
#  id            :integer         not null, primary key
#  message_id    :integer         not null
#  receiver_id   :integer         not null
#  receiver_type :string(255)     not null
#  kind          :string(255)     not null
#  position      :integer
#  state         :string(255)     not null
#  hidden_at     :datetime
#
# Indexes
#
#  index_message_recipients_on_message_id_and_kind_and_position  (message_id,kind,position) UNIQUE
#

class MessageRecipient < ActiveRecord::Base
  has_many  :notifications_as_origin,
            :class_name   => 'Notification',
            :foreign_key  => :origin_id,
            :conditions   => { :subject_type => 'Message' },
            :dependent    => :destroy

  def new_message_subject
    [ message.sender.display_name,
      "sent you a message"].join(' ')
  end
end
