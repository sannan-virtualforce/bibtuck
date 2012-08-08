class ExperiencesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @item = Item.find(params[:item_id])
    @user = @item.user
    @experience = Experience.new(:item => @item, :user => @item.user)
    verify_rating_unique
  end

  def index
    @user = User.find(params[:user_id])
    @experiences = @user.experiences
  end

  def create
    @user = User.find(params[:user_id])
    @experience = @user.experiences.new(params[:experience].merge(:rater => current_user))
    @item = @experience.item
    verify_rating_unique

    if @experience.save
      render :thank_you
    else
      render :new
    end
  end

  def verify_rating_unique
    if Experience.exists?(:rater_id => current_user.id, :item_id => @item.id, :user_id => @item.user.id)
      flash[:notice] = "You cannot rate the same item twice."
      redirect_to :back
    end
  end
end
