class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :update, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :destroy]

  def new
    if session[:registration_code_id].present? || params[:invitation_token]
      super
    else
      redirect_to page_path('no_invite')
    end
  end

  def create
    build_resource

    if resource.save
      resource.process_registration!
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        flash[:popup_notice] = { :id => :how_it_works_video, :popupwidth => 600 }
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render_with_scope :new }
    end
  end

  # Override registration update to handle new invitations with the full form.
  def update
    token = params[:user][:invitation_token]

    if token.present?
      self.resource = User.where(:invitation_token => token).first
      resource.attributes = params[:user]
      resource.accept_invitation!

      if resource.errors.empty?
        resource.save!
        resource.process_invite!
        sign_in(resource_name, resource)
        flash[:popup_notice] = { :id => :how_it_works_video, :popupwidth => 600 }
        redirect_to :root
      else
        resource.invitation_token = token
        render '/devise/registrations/new', :layout => 'sessions'
      end
    else
      authenticate_scope!
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      super
    end

    @user = resource
  end
end
