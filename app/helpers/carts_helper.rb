module CartsHelper

  # Note: Bug in Rails with rel attribute that was fixed just after 3.0.9 release
  def cart_link(item, cart = false, no_popup = false)
    return content_tag(:p, please_sign_in) unless user_signed_in?
    if current_user != item.user
      if current_cart.has_item?(item)
        remove_from_cart(item, cart, no_popup)
      else
        add_to_cart(item, no_popup)
      end
    end
  end

  def hidden_cart_link(item, no_popup = false)
    content_tag(:a,
                "xaddx",
                :href         => cart_path(current_user, :item_id => item.id, :no_popup => no_popup),
                :style        => 'display: none;',
                :class        => 'hidden add_to_cart',
                :rel          => 'nofollow' + (no_popup ? '' : ' facebox.item_added_to_cart_popup'),
                'data-method' => :put)
  end

  def checkout_link(opts = {})
    if current_cart.total_bucks > current_user.buck_balance
      opts[:link_text] = 'Checkout'
      not_enough_bucks nil, opts
    else
      link_to 'Checkout', new_order_path, opts 
    end
  end

  #TODO Do "we" just want to link to items_path,
  # or do we actually want to go back to where we were?
  def continue_shopping_link(opts = {})
    link_to 'Continue Shopping', items_path, opts
  end

protected

  #TODO we probably want to link back to the page they were on.
  #not too sure how we go about doing that
  def please_sign_in
    link = link_to('sign in', new_user_session_path)
    "Please #{link} to add this item to your cart.".html_safe
  end

  def remove_from_cart(item, cart, no_popup = false)
    if cart
      link_to 'Remove', cart_path(current_cart, :item_id => item.id,
        :cart_page => true, :no_popup => no_popup), :method => :delete
    else
      content_tag :a, 'Remove from cart', :href => cart_path(current_cart, :item_id => item.id, :no_popup => no_popup),
        :rel => 'nofollow' + (no_popup ? '' : ' facebox.item_removed_from_cart_popup'), 'data-method' => :delete, :class => 'grey_button'
    end
  end

  def add_to_cart(item, no_popup = false)
    if current_user.can_afford?(item)
      enough_bucks(item, no_popup)
    else
      not_enough_bucks(item)
    end
  end

  def enough_bucks(item, no_popup = false)
    content_tag(:a,
                "Add to Cart",
                :href         => cart_path(current_user, :item_id => item.id, :no_popup => no_popup),
                :rel          => 'nofollow' + (no_popup ? '' : ' facebox.item_added_to_cart_popup'),
                :class        => 'grey_button',
                'data-method' => :put)
  end

  def not_enough_bucks(item = nil, opts = {})
    link_text = opts[:link_text] || "Add to cart"
    css_class = opts[:css_class] || 'grey_button'
    link_to(link_text,
            not_enough_buck_purchases_path(:item_id => item.try(:id)),
            :rel    => 'facebox',
            :popupwidth => 385,
            :class  => css_class)
  end

end
