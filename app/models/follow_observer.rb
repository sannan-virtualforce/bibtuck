class FollowObserver < ActiveRecord::Observer

  def after_create(follow)
    Notification.create(
      :template => 'new_follow',
      :user     => follow.following,
      :actor    => follow.follower,
      :subject  => follow.following,
      :origin   => follow
    )
  end

end
