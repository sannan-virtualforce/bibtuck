class FollowsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @follow_with = current_user.follows_with(@user)
    @second_degree_followers = current_user.second_degree_followers(@user)
  end

  def create
    @follow = current_user.following_follows.new(params[:follow])
    respond_to do |format|
      if @follow.save
        @message = "You are now following #{h(@follow.following.display_name)}"
      else
        @message = "There was an error adding #{h(@follow.following.display_name)} to your follow list."
      end
      format.html { redirect_to @follow.following, :notice => @message }
      format.js
    end
  end

  def destroy
    @follow = current_user.following_follows.find(params[:id])
    @follow.destroy
    @message = "You are no longer following #{h(@follow.following.display_name)}"
    respond_to do |format|
      format.html { redirect_to @follow.following, :notice => @message }
      format.js
    end
  end

end
