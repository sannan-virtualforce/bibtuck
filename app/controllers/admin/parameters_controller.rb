class Admin::ParametersController < AdminController

  def index
    @parameters = Parameter.all
  end

  def edit
    @parameter = Parameter.find(params[:id])
  end

  def update
    @parameter = Parameter.find(params[:id])
    if @parameter.update_attribute :value, params[:parameter][:value]
      redirect_to admin_parameters_path, :notice => 'Sucessfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @parameter = Parameter.find(params[:id])
    if @parameter
      @parameter.update_attribute :value, nil
    end
    redirect_to admin_parameters_path
  end

end
