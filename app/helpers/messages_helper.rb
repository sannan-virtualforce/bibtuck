module MessagesHelper

  def messages_link
    if current_user
      link_text = []
      link_text << 'Messages'
      if current_user.user_conversations.unread.count > 0
        link_text << current_user.user_conversations.unread.count
        link_text << 'unread'
      end
      link_text = link_text.join(' ')
      raw link_to(link_text, user_conversations_path(current_user))
    else
      ''
    end
  end

  def replies_for(message)
    reply = ""
    orig = @message.original_message
    while orig
      msg = "#{orig.sender.full_name} says: #{orig.body}"
      reply << content_tag(:p, msg)
      orig = orig.original_message
    end
    raw reply
  end

  def send_message_to(user, opts = {})
    convo = current_user.convo_with(user)
    if convo.blank?
      link_to(opts[:link] || "Send #{user.display_name} a message",
              new_user_conversation_path(current_user, :to_user_id => user.id),
              :rel => 'facebox.new_message_popup')
    else
      link_to(opts[:link] || "Send #{user.display_name} a message",
              edit_user_conversation_path(current_user, convo, :to_user_id => user.id),
              :rel => 'facebox.new_message_popup')
    end
  end

end
