module Admin::ItemsHelper
  def render_state_change_actions(item)
    case item.state
    when 'open'
      link_to('Mark as Listed', change_state_admin_item_path(item, :state => :listed))
    when 'listed'
      link_to('Mark as Unlisted', change_state_admin_item_path(item, :state => :open))
    when 'shipping'
      if item.order_item && item.order_item.pending?
        link_to('Mark as Shipped', change_state_admin_item_path(item, :state => :shipped)) + ' ' +
        link_to('Mark as Delivered', change_state_admin_item_path(item, :state => :delivered)) + ' ' +
        link_to('Mark as Canceled', change_state_admin_item_path(item, :state => :canceled))
      elsif item.order_item && item.order_item.shipped?
        link_to('Mark as Delivered', change_state_admin_item_path(item, :state => :delivered)) + ' ' +
        link_to('Mark as Canceled', change_state_admin_item_path(item, :state => :canceled))
      end
    end
  end
end
