class Admin::ShippingBoxesController < AdminController

  def index
    @box_sizes = Category::BOX_SIZES_ENDICIA
    @totals = [] 
    User.where(:last_sign_in_at.ne => nil).each do |user|
      address = user.shipping_box_deliveries.first.try(:address) || user.primary_shipping_address || (user.shipping_addresses.count == 1 ? user.shipping_addresses.first : nil)
      next unless address
      sold_items = {}
      sent_boxes = {}
      remaining_boxes = {}
      @box_sizes.each do |size, label|
        sold_items[size] = Item.where(:user => user, :tucked_at.ne => nil, :shipping_box_size => size).count
        sent_boxes[size] = user.shipping_box_amount_delivered(size)
        remaining_boxes[size] = sent_boxes[size] - sold_items[size]
      end
      @totals << {
        :user => user,
        :address => address,
        :sold => sold_items,
        :sent => sent_boxes,
        :remaining => remaining_boxes,
        :sent_at => ShippingBoxDelivery.where(:user => user).maximum(:sent_at),
        :requested_at => ShippingBoxDelivery.where(:user => user).minimum(:requested_at)
      }
    end
    @totals.sort! do |t1, t2|
      if t1[:requested_at]
        if t2[:requested_at]
          t1[:requested_at] <=> t2[:requested_at]
        else
          -1
        end
      elsif t2[:requested_at]
        1
      else
        t1[:remaining].values.sum <=> t2[:remaining].values.sum
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @box_sizes = Category::BOX_SIZES_ENDICIA
    @boxes = []
    @box_sizes.each do |size, label|
      items_sold = Item.where(:user => @user, :tucked_at.ne => nil, :shipping_box_size => size).count
      sent_boxes = @user.shipping_box_amount_delivered(size)
      @boxes << {
        :size => size,
        :label => label,
        :remaining => sent_boxes - items_sold
      }
    end
    render :layout => 'popup'
  end

  def set_amounts
    @user = User.find(params[:id])
    if @user
      box_sizes = Category::BOX_SIZES_ENDICIA
      box_sizes.each do |size, label|
        box_amount = params[:box][size]
        if box_amount
          delivery = @user.shipping_box_deliveries.find_by_box_size(size)
          if delivery
            delivery.update_attributes :amount => (delivery.amount + box_amount.to_i), :sent_at => Time.now, :requested_at => nil
          else
            @user.shipping_box_deliveries.create(:box_size => size, :amount => box_amount.to_i, :sent_at => Time.now)
          end
        end
      end
    end
    redirect_to admin_shipping_boxes_path
  end

end
