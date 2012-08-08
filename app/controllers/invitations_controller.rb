class InvitationsController < Devise::InvitationsController
  include Devise::Controllers::InternalHelpers

  def edit
    self.resource = User.where(:invitation_token => params[:invitation_token]).first
    render :template => '/devise/registrations/new', :layout => 'sessions'
  end

  # POST /resource/invitation
  def create
    @pending = current_user.invitees.where('confirmed_at is null').order('created_at DESC')
    @accepted = current_user.invitees.where('confirmed_at is not null').order('created_at DESC')
    users = []

    params[:emails].each_with_index do |email, idx|
      if email.present?
        name = params[:names][idx]

        if name.blank?
          user = User.new(:email => email, :invite_name => name)
          user.errors.add_to_base("Name can't be blank")
        else
          user = resource_class.invite!({:email => email, :invite_name => name}, current_inviter)
        end

        if user.errors.present?
          self.resource = user
          return render :new
        else
          users << user
        end
      end
    end
    redirect_to new_user_invitation_path
  end

  def new
    build_resource
    @user = current_user
    @pending = @user.invitees.where('last_sign_in_at is null')
    @accepted = @user.invitees.where('last_sign_in_at is not null')
  end
end
