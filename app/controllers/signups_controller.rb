class SignupsController < ApplicationController

  skip_before_filter :redirect_to_sign_in_page

  def create
    @signup = Signup.new(params[:signup])

    if @signup.valid?
      if params[:signup][:code].present?
        session[:registration_code_id] = @signup.registration_code.id
      end
      redirect_to [:new, :user, :registration]
    else
      redirect_to :root
    end
  end

end
