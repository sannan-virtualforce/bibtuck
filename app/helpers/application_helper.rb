module ApplicationHelper
  def shipping_box_collection
    {
      "Small - USPS Regional Rate Box A" => :a,
      "Large - USPS Regional Rate Box B" => :b
    }
  end

  def shipping_box_size_label(label)
    shipping_box_collection.key(label.to_sym)
  end

  def nl2br(s)
      s.gsub(/\n/, '<br>')
  end

  def tucked_item_state(item, category = nil)
    return item.state.titlecase unless item.order_item.present?
    if item.buck_refund
      render 'activity_refund', :item => item
    else
      if category == :sold || !item.order_item.pending?
        item.order_item.shipping_status.titlecase
      else
        link_to item.order_item.shipping_status.titlecase, [:extended_state, item], :rel => :facebox
      end
    end
  end

  def twitter_link(order)
    text = if order.items.count > 1
                    "I just tucked a #{order.items.first.name} and more from @Bibtuck. #tuckyourselfin."
                  else
                    "I just tucked the #{order.items.first.name} from @Bibtuck. #tuckyourselfin."
      end

    link_to 'Tweet', "https://twitter.com/share?text=#{text}&url=http://www.tucked-in.com", :class => 'twitter-share-button', 'data-lang' => :en
  end

  def add_param(hsh)
    params.merge(hsh)
  end

  def user_admin?
    current_user && current_user.admin?
  end

  def bt_timestamp(obj)
    return false if obj.blank?

    if obj.is_a?(Date)
      l obj.to_date, :format => :bt
    else
      l obj, :format => :bt
    end
  end

  def bt_text_timestamp(obj)
    return false if obj.blank?

    if Date.today == obj
      "Today"
    elsif (Date.today - 1.day) == obj
      "Yesterday"
    else
      bt_timestamp(obj)
    end
  end

  def format_date(date)
    return unless date
    if date.kind_of?(Date)
      date = date.to_time
    end
    date.to_s :bt_date
  end

  def format_date_time(date_time)
    return unless date_time
    date_time.to_s :bt_date_time
  end

  def number_to_bucks(price, buck_case = :lower)
    bucks = (price == 1 ? 'buck' : 'bucks')
    bucks = case buck_case
      when :upper 
        bucks.upcase
      when :capital
        bucks.capitalize
      when :none
        ''
      else
        bucks
      end
    number_to_currency price, :precision => 0, :unit => bucks, :format => "%n %u"
  end

  def last_in_row?(index, row_length)
    if row_length != 1 && index + 1 == row_length
      'last'
    end
  end

  #NOTE we use html safe here because of all of the concatenation business.
  def sidebar(user = nil)
    content_tag(:div, :id => 'sidebar') {
      if user
        concat(content_tag(:p, username(user)))
        concat(profile_picture(user))
      end
      concat(render(:partial => 'shared/user_nav')) if viewing_current_user?
    }.html_safe
  end

  def render_errors(error_object, main_message = nil)
    return unless error_object.errors.any?
    main_message ||= "#{pluralize(error_object.errors.count, 'error')} prohibited this #{error_object.class.name.downcase} from being saved: "
    content_tag(:div, :id => 'error_explanation') do
      concat(content_tag(:h2, main_message))
      concat(content_tag(:ul) do
        error_object.errors.full_messages.each { |msg| concat(content_tag(:li, msg)) }
      end)
    end
  end

  def render_popup_notice
    if flash[:popup_notice]
      if flash[:popup_notice].kind_of?(String)
        render :partial => 'popup_notices/message', :layout => 'popup_notices/layout', :locals => {:message => flash[:popup_notice]}
      else
        render :partial => "popup_notices/#{flash[:popup_notice][:id]}", :layout => 'popup_notices/layout', :locals => flash[:popup_notice]
      end
    end
  end

  def show_promotional_message
    promotional_message = Parameter[:promotional_message]
    if promotional_message && promotional_message.value.present?
      content_tag :div, :id => :promotional_message do
        raw promotional_message.value
      end
    end
  end
end
