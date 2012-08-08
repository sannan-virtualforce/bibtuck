class Admin::RegistrationCodesController < AdminController

  def index
    @registration_codes = RegistrationCode.all
  end

  def show
    @registration_code = RegistrationCode.find(params[:id])
  end

  def new
    @registration_code = RegistrationCode.new
  end

  def edit
    @registration_code = RegistrationCode.find(params[:id])
  end

  def create
    @registration_code = RegistrationCode.new(params[:registration_code])

    if @registration_code.save
      redirect_to(admin_registration_codes_path, :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @registration_code = RegistrationCode.find(params[:id])

    if @registration_code.update_attributes(params[:registration_code])
      redirect_to(admin_registration_codes_path, :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @registration_code = RegistrationCode.find(params[:id])
    @registration_code.destroy

    redirect_to(admin_registration_codes_url)
  end

end
