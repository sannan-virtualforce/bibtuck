class AdminController < ApplicationController

  include ItemsHelper
  include UsersHelper

  layout 'admin'
  before_filter :require_admin

  def search
    fetch_search_results
  end

  def export_csv(name)
    respond_to do |format|
      format.csv {
        outfile = "#{name}-" + Time.now.strftime("%Y-%m-%d") + ".csv"
        csv_data = CSV.generate do |csv|
          yield(csv)
        end
        send_data csv_data,
          :type => 'text/csv; charset=utf-8; header=present',
          :disposition => "attachment; filename=#{outfile}"
      }
    end
  end

  def export_orders
    export_csv('order') do |csv|
      csv << [
        'Order ID',
        'Date tucked',
        'Buyer ID',
        'Buyer name',
        'Buyer email',
        'Shipping to address',
        'Total fee [$]',
        'Discount code',
        'Item ID',
        'Item name',
        'Date bibbed',
        'Seller ID',
        'Seller name',
        'Seller email',
        'Shipping from address',
        'Item price [Bucks]',
        'Shipping status',
        'Tacking number',
        'Refund status'
      ]
      Order.where(:is_complete => true)
        .includes(:items => [:user, :category, :buck_refund])
        .order(:created_at)
        .each do |order|
        order.order_items.each do |order_item|
          csv << [
            order.id,
            order.created_at,
            order.user.id,
            order.user.display_name,
            order.user.email,
            order.to_addr.to_s,
            order.total_fees/100,
            order.discount.present? ? order.discount.code : '',
            order_item.item.id,
            order_item.item.name,
            order_item.item.bibbed_at,
            order_item.seller.id,
            order_item.seller.display_name,
            order_item.seller.email,
            order_item.from_addr.to_s,
            order_item.item.price.round,
            get_shipping_status(order_item),
            order_item.tracked? ? order_item.tracking_number : '',
            get_refund_status(order_item.item)
          ]
        end
      end
    end
  end

  def export_items
    export_csv('items') do |csv|
      csv << [
        'Item ID',
        'Name',
        'Brand',
        'Category',
        'Size',
        'Fit',
        'Condition',
        'Price',
        'Description',
        'Why sell',
        'Seller ID',
        'Seller name',
        'Shipping from address',
        'Shipping box size',
        'Uploaded at',
        'Tucked at',
        'Status',
        'Editors pick',
        'Flagged',
        'Rating',
        'Refund',
        'Views total [All]',
        'Views total [Quick View]',
        'Views session [All]',
        'Views session [Quick View]',
        'Views users'
      ]
      Item.all.each do |item|
        csv << [
          item.id,
          item.name,
          item.brand.try(:name),
          item.category.name,
          item.size,
          item.fit,
          item.condition,
          item.price,
          item.description,
          item.why_sell,
          item.user.id,
          item.user.display_name,
          item.shipping_from_address.try(:to_s),
          item.shipping_box_size,
          item.bibbed_at,
          item.tucked_at,
          get_item_status(item),
          item.editors_pick ? 'Yes' : nil,
          item.flagged? ? 'Yes' : nil,
          item.experience.try(:rating),
          get_refund_status(item),
          item.view_count_total,
          item.view_count_total_qv,
          item.view_count_session,
          item.view_count_session_qv,
          item.view_count_distinct_user
        ]
      end
    end
  end

  def export_users
    export_csv('users') do |csv|
      csv << [
        'User ID',
        'First name',
        'Last name',
        'Username',
        'Email',
        'Birthday',
        'Age',
        'Location',
        'Occupation',
        'About me',
        'Member since',
        'Last login',
        'Website URL',
        'Twitter',
        'Facebook',
        'Followed by',
        'Following',
        'Admin',
        'Founding member',
        'Top rated at',
        'Featured at',
        'Items bibbed',
        'Items sold',
        'Items purchased',
        'Buck balance [bucks]',
        'Amount of bucks purchased [bucks]',
        'Amount spent in fees [$]',
        'Amount spent in buck purchases [$]',
        'Total revenue [$]',
        'Refund requests received',
        'Refund requests accepted',
        'Refund requests rejected',
        'Refund requests sent',
        'Refund requests sent (accepted)',
        'Refund requests sent (rejected)',
        'Reported items',
        'Averate rating',
        '# of ratings received',
        '# of saved photos',
        '# of Editor\'s picks',
        'How did get to the website',
        '# of invitations remaining',
        '# of invitations accepted',
        '# of invitations pending'
      ]
      User.all.each do |user|
        - spent_usd_on_bucks = user.buck_purchases.map(&:amount_in_cents).sum/100
        - spent_usd_on_fees = user.orders.map(&:amount_in_cents).sum/100
        csv << [
          user.id,
          user.first_name,
          user.last_name,
          user.username,
          user.email,
          user.birthday,
          user.age,
          user.location,
          user.occupation,
          user.about_me,
          user.created_at,
          user.last_sign_in_at,
          user.website_url,
          user.twitter_username,
          user.facebook_page,
          user.followers_count,
          user.followings_count,
          user.admin ? 'Yes' : nil,
          user.founding_member_at ? 'Yes' : nil,
          user.top_rated_at,
          user.featured_at,
          user.items.where('bibbed_at is not null').count,
          user.items.sold.count,
          user.tucked_items.count,
          user.buck_balance,
          user.buck_purchases.map(&:bucks).sum,
          spent_usd_on_fees,
          spent_usd_on_bucks,
          spent_usd_on_fees + spent_usd_on_bucks,
          user.items.inject(0) { |sum, item| sum + (item.buck_refund ? 1 : 0) },
          user.items.inject(0) { |sum, item| sum + (item.buck_refund.try(:outcome) == :accepted ? 1 : 0) },
          user.items.inject(0) { |sum, item| sum + (item.buck_refund.try(:outcome) == :rejected ? 1 : 0) },
          user.buck_refunds.count,
          user.buck_refunds.where(:outcome_cd => 1).count,
          user.buck_refunds.where(:outcome_cd => 0).count,
          user.items.inject(0) { |sum, item| sum + (item.flagged_item ? 1 : 0 ) },
          user.average_rating ? user.average_rating.round(1) : nil,
          user.experiences.count,
          user.photos.available.count,
          Item.where(:user => user, :editors_pick => true).count,
          how_did_user_get_to_the_website_txt(user),
          user.invitation_limit,
          user.invitees.where(:last_sign_in_at.ne => nil).count,
          user.invitees.where(:last_sign_in_at => nil).count
        ]
      end
    end

  end

protected

  def require_admin
    unless user_admin?
      render :file => 'public/404.html', :layout => nil, :status => 404
      return false
    end
  end

  def user_admin?
    current_user && current_user.admin?
  end
end
