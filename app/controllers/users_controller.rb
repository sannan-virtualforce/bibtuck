class UsersController < ApplicationController
  before_filter :verify_identity, :only => [ :deactivate, :edit, :update, :bucks, :bucks ]
  before_filter :authenticate_user!

  def featured
    @user = User.find(params[:id])
    @featured_content = @user.featured_content
    @featured_items = distribute_into_columns_unordered(@user.items.bibbed.order('bibbed_at DESC'), 4) do |item|
      item.primary_photo ? ((213.0 / item.primary_photo.width * item.primary_photo.height).round + 16) : 0
    end
    @past_featured_closets = User.featured - [@user]
  end

  def index
    @user = current_user
    case params[:filter]
    when 'instagram', 'twitter'
      @filter = params[:filter]
      @not_implemented = true
    when 'facebook'
      @filter = 'facebook'
      auth = @user.authentications.find_by_provider(:facebook)
      if auth
        @facebook = Koala::Facebook::API.new(auth.token)
        @friends = @facebook.get_connections(auth.uid, 'friends')
        @friends = @friends.map { |friend| friend['id'] }
        @users = User.active
          .joins(:authentications)
          .where(:authentications => { :provider => :facebook, :uid => @friends })
          .order('followers_count desc, bibbed_items_count desc')
      else
        redirect_to '/auth/facebook'
        return
      end
    else
      @filter = 'suggested'
      @users = User.active.includes(:items)
        .where('username is not null')
        .order('followers_count desc, bibbed_items_count desc')
    end
    @users = @users.page(params[:page]).per(21) if @users
    if params[:page]
      render :layout => false
    end
  end

  def resend_invite
    @user = User.find(params[:id])
    if @user.send(:deliver_invitation)
      @user.touch :invitation_sent_at
      flash[:notice] = "Invitation sent successfully."
      redirect_to :back
    end
  end

  def activity
    @user             = current_user
    @current_sales    = @user.items.for_sale.order('bibbed_at DESC')
    @sold_items       = @user.items.sold.order('tucked_at DESC')
    @unlisted_items   = @user.items.unlisted.order('updated_at DESC')
    @purchased_items  = @user.tucked_items.order('tucked_at DESC')
    @show_expanded_activity = true
  end

  def saved_photos
    @user = User.find(params[:id])
    @photos = @user.photos.available.group_by(&:bib_hash)
  end

  def destroy_saved_photo
    @photo = current_user.photos.available.find(params[:photo_id])
    if @photo
      @photo.destroy
    else
      @error = 'Error deleting photo.'
    end
  end

  def destroy_saved_photos
    deleted_photos = []
    photos = params[:photo_ids]
    photos.each do |photo_id|
      photo = current_user.photos.available.find_by_id(photo_id)
      if photo
        photo.destroy
        deleted_photos << photo_id
      end
    end
    render :json => { :destroyed => deleted_photos }
  end

  def bucks
    @user = current_user
    @positive_transactions = @user.buck_transactions.positive
    @negative_transactions = @user.buck_transactions.negative
  end

  def show
    @user = User.find(params[:id])
    @second_degree_followers = @user.second_degree_followers(current_user)
    @items = @user.items.includes(:photos).bibbed
    @columns = distribute_into_columns_unordered(@items, 3) do |item|
      item.primary_photo ? ((213.0/item.primary_photo.width * item.primary_photo.height).round + 16) : 0
    end
  end

  def edit
    @user = current_user
  end

  def edit_email
    @user = current_user
    render :layout => false
  end

  def edit_password
    @user = current_user
    render :layout => false
  end

  def update_field
    @user = current_user
    @field_name = params[:field]
    if @user.valid_password?(params[:password])
      if @user.update_attributes(params[:user])
        @status = :ok
        @message = "Your #{@field_name} was successfully updated."
      else
        @status = :error
        @message = "There was an error updating your #{@field_name}."
      end
    else
      @status = :auth
      @message = 'Wrong password supplied.'
    end
    respond_to do |format|
      format.js
    end
  end

  def update_password
    @user = current_user
    if @user.valid_password?(params[:user][:current_password])
      if params[:user][:password] == params[:user][:password_confirmation]
        if @user.update_with_password(params[:user])
          sign_in(@user, :bypass => true)
          @status = :ok
          @message = 'Password successfully updated.'
        else
          @status = :error
        end
      else
        @status = :confirmation
        @message = 'Passwords do not match.'
      end
    else
      @status = :auth
      @message = 'Wrong old password supplied.'
    end
    respond_to  do |format|
      format.js
    end
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      redirect_to(@user)
    else
      flash[:notice] = "There was an error saving your settings."
      redirect_to :back
    end
  end

  def account
    @user = User.find(params[:id])
    @user.shipping_addresses.build if @user.shipping_addresses.blank?
  end

  def autocomplete_field_results
    if params[:q]
      query = "%#{params[:q].downcase}%"
      @users = User.registred.where('lower(first_name) like ? or lower(last_name) like ? or lower(username) like ? or lower(email) like ?', query, query, query, query)
    else
      @users = User.registred
    end
    render :layout => false
  end

  def request_shipping_boxes
    @user = current_user
    render :layout => 'popup'
  end

  def post_shipping_boxes_request
    user = current_user
    address = user.shipping_addresses.find(params[:address_id])
    if user.shipping_box_deliveries.present?
      ShippingBoxDelivery.update_all({:requested_at => Time.now, :address_id => address.try(:id)}, {:user => current_user})
    else
      Category::BOX_SIZES_ENDICIA.each do |size, label|
        user.shipping_box_deliveries.create(:box_size => size, :requested_at => Time.now, :address_id => address.try(:id))
      end
    end
    flash[:notice] = "Request for shipping boxes successfully sent."
    redirect_to :back
  end

protected

  def verify_identity
    # FIXME simplify
    if !User.where(:id => params[:id]).present? || current_user != User.find(params[:id])
      redirect_to [:edit, current_user], :notice => "You are not authorized to see this page."
    end
  end

end
