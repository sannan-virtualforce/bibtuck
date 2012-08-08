class Admin::LookbookPhotosController < AdminController

  def index
    @lookbook_photos = LookbookPhoto.all
  end

  def show
    @lookbook_photo = LookbookPhoto.find(params[:id])
  end

  def new
    @lookbook_photo = LookbookPhoto.new
  end

  def edit
    @lookbook_photo = LookbookPhoto.find(params[:id])
  end

  def create
    @lookbook_photo = LookbookPhoto.new(params[:lookbook_photo])

    if @lookbook_photo.save
      redirect_to([:admin, @lookbook_photo], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @lookbook_photo = LookbookPhoto.find(params[:id])

    if @lookbook_photo.update_attributes(params[:lookbook_photo])
      redirect_to([:admin, @lookbook_photo], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @lookbook_photo = LookbookPhoto.find(params[:id])
    @lookbook_photo.destroy
    flash[:notice] = "Destroyed lookbook photo"

    redirect_to(admin_lookbook_photos_url)
  end

end
