class Admin::UsersController < AdminController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to([:admin, @user], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to([:admin, @user], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to(admin_users_url)
  end

  def activate
    @user = User.find(params[:id])
    if @user
      @user.update_attribute :deactivated_at, nil
      @user.update_attribute :deactivation_reason, nil
    end
    redirect_to :back
  end

  def deactivate_popup
    @user = User.find(params[:id])
    render :layout => 'popup'
  end

  def deactivate
    @user = User.find(params[:id])
    if @user
      @user.touch :deactivated_at
      @user.update_attribute :deactivation_reason, params[:reason]
      CartItem.joins(:item).where(:item => { :user_id => @user.id }).each do |cart_item|
        cart_item.destroy
      end
    end
    redirect_to :back
  end

end
