module NavigationHelper

  def is_selected_page?(page_label)
    if request.request_uri =~ /^\/admin/
      return page_label == :admin ? selected_class : nil
    end
    is_selected = false;
    case page_label
    when :bib
      if controller.controller_name == 'items'
        if controller.action_name =~ /new|edit/
          is_selected = true
        elsif controller.action_name == 'show'
          is_selected = current_user.can_modify?(@item) ? true : false
        end
      end
    when :tuck
      if controller.controller_name == 'items'
        if controller.action_name == 'index'
          is_selected = true
        elsif controller.action_name == 'show'
          is_selected = current_user.can_modify?(@item) ? false : true
        end
      end
    when :my_profile
      is_selected = true if current_page?(current_user) || current_page?(edit_user_path(current_user))
    when :members
      is_selected = true if current_page? users_path
    when :notifications
      is_selected = true if controller.controller_name == 'notifications'
    when :bucks
      is_selected = true if ((controller.controller_name == 'users' && controller.action_name == 'bucks') || 
                              controller.controller_name == 'buck_purchases')
    when :cart
      is_selected = true if controller.controller_name =~ /carts|orders/
    end
    is_selected ? selected_class : nil
  end

protected

  def selected_class
    'selected'
  end

end
