class Admin::FeaturedClosetsController < AdminController

  def index
    @featured_closets = User.featured
  end

  def set_current
    @user = User.find(params[:id])
    @user.featured_at = Time.new
    @user.save
    redirect_to admin_featured_closets_path
  end

  def destroy
    @user = User.find(params[:id])
    @user.featured_at = nil
    @user.save
    redirect_to admin_featured_closets_path
  end

  def edit
    @user = User.find(params[:id])
    @featured_content = @user.featured_content
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to admin_featured_closets_path
    else
      render :action => 'edit'
    end
  end

end
