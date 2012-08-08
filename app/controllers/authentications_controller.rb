class AuthenticationsController < ApplicationController

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully."
      authentication.name = "#{omniauth['info']['name']}"
      authentication.token = omniauth['credentials']['token']
      authentication.expires_at = Time.at(omniauth['credentials']['expires_at'])
      authentication.save
      sign_in(:user, authentication.user)
      redirect_to root_path
    elsif current_user
      current_user.authentications.create(
        :provider => omniauth['provider'],
        :uid => omniauth['uid'],
        :name => "#{omniauth['info']['name']}",
        :token => omniauth['credentials']['token'],
        :expires_at => Time.at(omniauth['credentials']['expires_at'])
      )
      flash[:notice] = "Authorization successful."
      redirect_to request.env['omniauth.origin']
    else
      flash[:popup_notice] = "Members can only Login through Facebook once they've authorized the Facebook app under account settings."
      redirect_to new_user_session_path
    end
  end

  def destroy
    authentication = current_user.authentications.find(params[:id])
    authentication.destroy
    redirect_to account_user_path(current_user)
  end

protected

  def handle_unverified_request
    true
  end

end
