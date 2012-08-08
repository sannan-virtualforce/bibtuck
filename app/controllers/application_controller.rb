class ApplicationController < ActionController::Base

  before_filter :redirect_to_sign_in_page

  before_filter :mandatory_autorization_code_for_signup
  protect_from_forgery :except => :aviary_callback

  layout :layout_by_resource

  unless ActionController::Base.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    rescue_from ActionController::RoutingError, :with => :render_404
    rescue_from ActionController::UnknownController, :with => :render_404
    rescue_from ActionController::UnknownAction, :with => :render_404
  end

protected

  def mandatory_autorization_code_for_signup
    if (params[:controller] == "devise/registrations") &&
        (params[:action] == "new" || params[:action] == "create")
      unless session[:registration_code_id].present?
        redirect_to [:new, :signup], :notice => 'Invalid invitation code. Please try again.'
      end
    end
  end

  def fetch_search_results
    @query = "%#{params[:query]}%" if params[:query].present?
    @users = User.active.where("last_sign_in_at is not null and (lower(last_name) like ? or lower(first_name) like ? or lower(email) like ? or lower(username) like ?)", @query, @query, @query, @query)
    @items = Item.active.bibbed.where('lower(name) like ?', @query)
    @brands = Brand.where('lower(name) like ?', @query)
    @results = [@users, @items, @brands].flatten.compact
  end

  def authorize_current_user(obj)
    if !current_user.can_modify?(obj)
      flash[:notice] = "You are not authorized to view this page."
      return redirect_to :back
    end
  end

  def current_cart
    unless @current_cart
      @current_cart = Cart.find_by_user_id(current_user.id)
      unless @current_cart
        @current_cart = Cart.create(:user => current_user)
      end
    end
    @current_cart
  end
  helper_method :current_cart

  def h(string)
    ERB::Util.html_escape(string)
  end

  def render_splash
    render 'home/splash', :layout => 'splash'
  end

  def render_404
    render 'errors/404', :layout => false, :status => :not_found
  end

  def render_500
    render 'errors/500', :layout => false, :status => 500
  end

  #TODO How do you NOT have to do this with devise?
  def layout_by_resource
    not_invitation_controller?
    if devise_controller? &&
        not_invitation_controller? &&
        ((resource_name == :user && action_name == 'new') ||
         (controller_name == 'registrations' && action_name == 'create'))
      "sessions"
    else
      "application"
    end
  end

  def not_invitation_controller?
    controller_name != 'invitations'
  end

  def distribute_into_columns_ordered(items, num_of_cols, &item_height)
    columns = []
    heights = []
    num_of_cols.times do
      columns << []
      heights << 0
    end
    empty_count = num_of_cols
    items.each do |item|
      height = item_height.call(item)
      if empty_count > 0
        columns[-empty_count] << item
        heights[-empty_count] += height
        empty_count -= 1
      else
        current_col = num_of_cols - 1
        columns[current_col] << item
        heights[current_col] += height
        while current_col > 0
          height = item_height.call(columns[current_col].first)
          while (heights[current_col - 1] + height < heights[current_col]) && columns[current_col].length > 1
            shifted_item = columns[current_col].shift
            heights[current_col] -= height
            columns[current_col - 1] << shifted_item
            heights[current_col - 1] += height
            shifted = true
            height = item_height.call(columns[current_col].first)
          end
          current_col = shifted ? current_col - 1 : 0
        end
      end
    end
    return columns
  end

  def find_min_value_column(columns)
    columns.each_with_index.inject(0) do |min_idx, (col_h, col_idx)|
      col_h < columns[min_idx] ? col_idx : min_idx
    end
  end

  def distribute_into_columns_unordered(items, num_of_cols, heights = nil, &item_height)
    unless heights
      heights = []
      num_of_cols.times { heights << 0 }
      min_column = 0
    else
      min_column = find_min_value_column(heights)
    end
    columns = []
    num_of_cols.times { columns << [] }
    items.each do |item|
      height = item_height.call(item)
      next if height == 0
      columns[min_column] << item
      heights[min_column] += height
      min_column = find_min_value_column(heights)
    end
    return columns
  end

  def get_column_heights(items, num_of_cols, num_items = nil, &item_height)
    num_items ||= items.length
    heights = []
    min_column = 0
    num_of_cols.times do
      heights << 0
    end
    items.each_with_index do |item, idx|
      break if idx >= num_items
      height = item_height.call(item)
      next if height == 0
      heights[min_column] += height
      min_column = heights.each_with_index.inject(0) do |min_idx, (col_h, col_idx)|
        col_h < heights[min_idx] ? col_idx : min_idx
      end
    end
    return heights 
  end

  def after_sign_in_path_for(resource_or_scope)
    flash[:notice] = "Hi #{current_user.first_name}, Happy #{Time.now.strftime '%A'}!"
    super
  end

  def redirect_to_sign_in_page
    return nil if current_user
    return nil if params[:controller] == "devise/registrations"
    return nil if params[:controller] == "devise/passwords"
    return nil if params[:controller] == 'pages'
    return nil if params[:controller] == 'invitations'
    return nil if params[:controller] == 'registrations'
    return nil if params[:controller] == 'buck_refunds'
    return nil if params[:controller] == 'authentications'
    redirect_to new_user_session_path
  end
end
