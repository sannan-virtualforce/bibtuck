class Admin::CreditsController < AdminController

  def index
    @credits = Credit.all
  end

  def show
    @credit = Credit.find(params[:id])
  end

  def new
    @credit = Credit.new(:user_id => params[:user_id])
  end

  def edit
    @credit = Credit.find(params[:id])
  end

  def create
    @credit = Credit.new(params[:credit])

    if @credit.save
      redirect_to([:admin, @credit], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @credit = Credit.find(params[:id])

    if @credit.update_attributes(params[:credit])
      redirect_to([:admin, @credit], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @credit = Credit.find(params[:id])
    @credit.destroy

    redirect_to(admin_credits_url)
  end

end
