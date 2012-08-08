module ItemsHelper

  def item_photo_tag(photo, opts = {})
    img = image_tag(photo.path_url(opts[:photo_size] || :big),
      :id => dom_id(photo),
      :big_url => photo.path_url(:big),
      :original_url => photo.path_url,
      :class => opts[:css_class].uniq.join(' ')
    )

    if opts[:css_class].member?('zoom')
      link_to photo.path_url, :class => :zoom do
        img
      end
    else
      img
    end
  end

  def render_colors(colors)
    if colors.kind_of?(Item)
      colors = colors.color.try(:split)
    elsif colors.kind_of?(String)
      colors = colors.split
    end
    return unless colors.present?
    content_tag :div, :class => :colors_display do
      colors.each do |color|
        concat content_tag(:div, '', :class => :box, :style => "background-color:#{color}")
      end
    end
  end

  def thumbnail_for(item, opts = {})
    return '' unless item.try(:primary_photo)
    link_to(image_tag(item.primary_photo.path_url(:thumb)), item, opts)
  end

  def viewing_my_item?
    @item.user == current_user
  end

  def list_action_link(item, opts = {})
    return unless user_signed_in?
    return unless current_user.can_modify?(item)
    return unless item.can_modify_list_status?

    if item.listed?
      link_to('Unlist item',
              unbib_item_path(item),
              :method   => :put,
              :confirm  =>  "Are you sure you want " +
                            "to unlist this item?",
              :class => opts[:class])
    end
  end

  def explanation(field)
    if explanations[field]
      content_tag(:div, explanations[field], :class => 'explanation')
    end
  end

  def report_item(item)
    link_to('Report this item',
            new_item_flagged_item_path(item),
            :class => :report_button,
            :rel => :facebox)
  end

private

  def explanations
    {
      :brand => "if we don't have your item's brand, please include it here and we will add it to our brand index.",
      :description => "what's the material? does it run true to size? does it need to be dry-cleaned? is there a story behind it? if it's anything short of excellent condition, list any 'flaws'. tell us as much as you'd wanna know.",
      :why_sell => "be honest, is there something we need to know?",
      :price => "bucks are based on monetary value, so imagine how many dollars you would bib/tuck it for in its current condition"
    }
  end

  def is_current_sort_order?(label)
    if params['sort']
      params['sort'] == label.to_s ? 'current' : nil
    else
      label == :newest ? 'current' : nil
    end
  end

  def is_current_filter?(label)
    if !params['filter'] && label.to_s == 'whats_new'
      return 'current'
    end
    params['filter'] == label.to_s ? 'current' : nil
  end

  def is_current_category?(category)
    if !params['category_id'] && category == :all
      return 'current'
    end
    params['category_id'].to_i == category ? 'current' : nil
  end

  def is_current_brand?(brand)
    if !params['brand_id'] && brand == :all
      return 'current'
    end
    params['brand_id'].to_i == brand ? 'current' : nil
  end

  def bib_brand_select_options
    Brand.where('bib_seq is not null').order(:bib_seq).map {|brand| [brand.name, brand.id]}
      .concat([['------------------------------', '']])
      .concat(Brand.where(:bib_seq => nil).order(:name).map {|brand| [brand.name, brand.id]})
  end

  def get_item_status(item)
    case item.state
    when 'open'
      status_msg = 'Unlisted'
    when 'listed'
      status_msg = 'Unsold'
    when 'shipping'
      if item.order_item
        if item.order_item.pending?
          status_msg = 'Sold - pending shipment'
        elsif item.order_item.shipped?
          status_msg = 'Sold - shipped'
        elsif item.order_item.delivered?
          status_msg = 'Sold - delivered'
        end
      else
        status_msg = 'INVALID'
      end
    when 'complete'
      if item.order_item
        if item.order_item.canceled?
          status_msg = 'Sold - canceled'
        else
          status_msg = 'Sold - delivered'
        end
      else
        status_msg = 'INVALID'
      end
    end
    return status_msg
  end

  def get_shipping_status(item)
    if item.kind_of?(Item)
      order_item = item.order_item
    elsif item.kind_of?(OrderItem)
      order_item = item
    end
    return nil unless order_item
    order_item.shipping_status.titlecase
  end

  def get_refund_status(item)
    if item.kind_of?(OrderItem)
      item = order_item.item
    end
    return nil unless item
    if item.buck_refund
      return nil unless item
      if item.buck_refund
        if item.buck_refund.accepted?
          'Refund accepted'
        elsif item.buck_refund.rejected?
          'Refund rejected'
        else
          'Refund requested'
        end
      end
    end
  end
end
