class SessionsController < Devise::SessionsController
  include Devise::Controllers::InternalHelpers
  before_filter :include_signup, :only => :new

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")

    if resource.deactivated?
      flash[:notice] = "Your account has been deactivated."
      sign_out resource
      return redirect_to root_url
    end

    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

protected

  def include_signup
    @signup = Signup.new
  end

end
