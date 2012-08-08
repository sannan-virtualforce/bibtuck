class Admin::PhotosController < AdminController
  def index
    @photos = Photo.all
  end

  def show
    @photo = Photo.find(params[:id])
  end

  def new
    @photo = Photo.new
    @referer = request.referer
    if params[:item_id]
      @item = Item.find(params[:item_id])
    end
  end

  def edit
    @photo = Photo.find(params[:id])
    @referer = request.referer
  end

  def create
    @photo = Photo.new(params[:photo])
    unless @photo.item
      @photo.curator = current_user
    end

    if @photo.save
      if params[:referer]
        redirect_to params[:referer]
      else
        redirect_to admin_photo_path(@photo), :notice => 'Successfully created.'
      end
    else
      render :action => "new"
    end
  end

  def update
    @photo = Photo.find(params[:id])

    if params[:path].present?
      @photo.remove_path!
    end

    if @photo.update_attributes(params[:photo])
      if params[:referer]
        redirect_to params[:referer]
      else
        redirect_to admin_photo_path(@photo), :notice => 'Successfully updated.'
      end
    else
      render :action => "edit"
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    if params[:referer]
      redirect_to params[:referer]
    else
      redirect_to :back
    end
  end
end
