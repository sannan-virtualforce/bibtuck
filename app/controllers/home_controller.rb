class HomeController < ApplicationController

  skip_before_filter :redirect_to_sign_in_page, :only => [:splash]

  def index
    @featured_closet  = User.featured.limit(1).first
    @top_rated_users  = User.top_rated.limit(5)
    @editors_picks    = Item.active.for_sale.filtered_by('editors_picks', current_user).limit(6)
    @new_items        = Item.active.bibbed.older_than(params[:last]).limit(6)
  end

  def splash
    render :layout => 'splash'
  end
end
