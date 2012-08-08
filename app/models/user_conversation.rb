class UserConversation < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation
  has_many :messages, :through => :conversation, :order => 'messages.created_at DESC'

  accepts_nested_attributes_for :conversation

  delegate :users, :to => :conversation

  attr_accessor :to
  before_create :create_user_conversations

  scope :unread, where(:read => nil)
  scope :active, where(:deleted => nil)

  def newest_message
    messages.order('created_at DESC').first
  end

  private

  def create_user_conversations
    return if to.blank?
    UserConversation.create(:user_id => to, :conversation => conversation)
  end
end
