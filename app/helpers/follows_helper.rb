module FollowsHelper

  def follow_button(user, opts = {})
    return '' unless current_user && current_user != user && user_signed_in?
    if current_user.follows(user)
      render :partial => 'follows/unfollow_button', :locals => {:user => user, :opts => opts}
    else
      render :partial => 'follows/follow_button', :locals => {:user => user, :opts => opts}
    end
  end

  def render_follows(follows)
    render( :partial    => 'users/mini_user',
            :collection => follows,
            :as         => :user)
  end

end
