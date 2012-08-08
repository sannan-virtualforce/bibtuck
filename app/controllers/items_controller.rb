class ItemsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  impressionist :actions => [:show, :quick_view]

  # GET /items
  def index
    @filter = params[:filter]

    @items = Item.active
      .where(:bibbed_at.ne => nil)
      .includes(:photos)
      .filtered_by(@filter, current_user)
      .sorted_by(params[:sort])
      .with_size(params[:size])

    @categories = Category.all

    if params[:size].present?
      @items = @items.where(:size => params[:size])
    end

    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @items = @items.where(:category_id => @category.id)
    end

    if params[:brand_id].present?
      @items = @items.where(:brand_id => params[:brand_id])
    end

    if params[:page] && (page = params[:page].to_i) > 1
      col_heights_prev_pages = get_column_heights(@items, 3, 15*(page - 1)) do |item|
        item.primary_photo ? ((213.0/item.primary_photo.width * item.primary_photo.height).round + 16) : 0
      end
    else
      col_heights_prev_pages = [0, 0, 0]
    end
    @items = @items.page(params[:page]).per(15)
    @columns = distribute_into_columns_unordered(@items, 3, col_heights_prev_pages) do |item|
      item.primary_photo ? ((213.0/item.primary_photo.width * item.primary_photo.height).round + 16) : 0
    end

    if params[:page]
      render 'continous_scroll_data', :layout => false
    end
  end

  def shipping_label
    @item = Item.find(params[:id])
    @generate_new = (current_user.admin? && params[:new] ? true : false)
    if @item.order_item.generate_shipping_label!(@generate_new)
      send_file File.join(OrderItem.shipping_labels_path, @item.order_item.shipping_label), :filename => "shipping_label_#{@item.id}.pdf", :type => 'application/pdf'
    end
    # else render error message in shipping_label view
  end

  # GET /items/1
  def show
    @item = Item.find(params[:id])
    @user = @item.user
    if request.referer =~ /\/search$/ || request.referer =~ /\/items\/\d+\/edit$/
      @hide_back_button = true
    end
  end

  def quick_view
    @item = Item.find(params[:id])
    render :layout => 'popup'
  end

  # GET /items/new
  def new
    if params[:relist]
      @source = Item.find(params[:relist])
      if @source
        @item = @source.clone
        @item.shipping_from_address = nil
        bib_hash = current_user.photo_hash
        @source.photos.each do |photo|
          photo_copy = Photo.new(:user => current_user, :bib_hash => bib_hash)
          photo_copy.path = File.open(File.join(Rails.root, 'public', photo.path.url))
          photo_copy.save
          @photo_ids ||= []
          @photo_ids << photo_copy.id
          @primary_photo_id = photo_copy.id if photo.is_primary?
        end
      end
    end
    @item ||= current_user.items.new
  end

  # GET /items/1/edit
  def edit
    @item = current_user.items.find(params[:id])
    authorize_current_user(@item)
    @item.attributes = params[:item]
    (4 - @item.photos.count).times do
      @item.photos.build
    end
  end

  def extended_state
    @item = Item.find(params[:id])

    if @item.buck_refund
      render :inline => "Refund was requested on: #{@item.buck_refund.created_at.to_date.strftime("%m.%d.%y")}", :layout => false
    else
      render :inline => @item.order_item.shipping_status_message, :layout => false
    end
  end

  # POST /items
  # POST /items.xml
  def create
    @item = current_user.items.new(params[:item])
    @item.photos = Photo.where('id in (?)', params[:photo_ids])
    @item.update_primary_photo params[:primary_photo_id]

    respond_to do |format|
      if @item.save
        format.html { redirect_to item_path(@item, :preview => true), :notice => "You're almost done. Scroll down to bib your item."}
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = current_user.items.find(params[:id])
    @item.photos = Photo.where('id in (?)', params[:photo_ids])
    @item.update_primary_photo params[:primary_photo_id]

    if @item.flagged?
      @item.flagged_item.user ||= current_user
    end

    @item.attributes = params[:item]
    @item.bibbed_at = Time.now if @item.bibbed_at

    if @item.save
      redirect_to(item_path(@item), :notice => 'Item successfully updated.')
    else
      render :action => "edit"
    end
  end

  def bib
    @user = current_user
    @item = @user.items.find(params[:id])
    if @item.bib
      unless @user.first_bib_at.present?
        @user.touch :first_bib_at
        buck_prize_first_bib = Parameter[:buck_prize_first_bib].value.to_i
        if buck_prize_first_bib > 0
          BuckTransaction.transaction do
            transaction = BuckTransaction.create(
              :user => @user,
              :reason => :first_bib,
              :reference => @item,
              :delta => buck_prize_first_bib
            )
            Notification.create!(
              :template => 'first_bib',
              :user => @user,
              :subject => @item,
              :actor => @user,
              :origin => transaction
            )
          end
        end
      end
      redirect_to(:items, :notice => 'You have successfully bibbed your item and it is now available for others to tuck!')
    else
      flash[:notice] = "You must fill out required fields and have at least one photo to be able to bib an item."
    end
  end

  def unbib
    @user = current_user
    @item = @user.items.find(params[:id])
    @item.unbib!
    redirect_to activity_user_path(@user), :notice => "You have unlisted this item."
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    if @item.open? || @item.listed?
      @item.destroy
    else
      flash[:notice] = "You can't delete this item."
    end

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end
end
