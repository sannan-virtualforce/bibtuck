class PhotosController < ApplicationController

  skip_before_filter :redirect_to_sign_in_page, :only => [:aviary_callback]

  def index
    @item = Item.find_by_id(params[:item_id])
    @photos = @item.try(:photos)

    if params[:photo_ids].present?
      @photos = Photo.where(:id => params[:photo_ids])
    end

    @photos ||= []

    respond_to do |format|
      format.json {
        render :json => @photos.collect { |p| p.to_jq_upload }.to_json
      }
      format.html
    end
  end

  def show
    @photo = current_user.photos.find(params[:id])
  end

  def new
    @photo = current_user.photos.new
  end

  def edit
    @photo = current_user.photos.find(params[:id])
    @security_token = Digest::SHA1.hexdigest(@photo.created_at.to_s)
  end

  def create
    @photo = current_user.photos.new(params[:photo])

    if @photo.save
      render :json => [@photo.to_jq_upload].to_json
    else
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  def update
    @photo = current_user.photos.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to(@photo, :notice => 'Photo was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def aviary_callback
    photo = Photo.find(params[:id])
    photo.fetch!(params[:url].to_s,
                 params[:k].to_s)
    redirect_to(photo.item)
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    @photo.destroy
    render :json => true
  end
end
