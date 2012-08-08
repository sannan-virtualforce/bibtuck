class Admin::RecommendationsController < AdminController

  def index
    @recommendations = Recommendation.all
  end

  def show
    @recommendation = Recommendation.find(params[:id])
  end

  def new
    @recommendation = Recommendation.new
  end

  def edit
    @recommendation = Recommendation.find(params[:id])
  end

  def create
    @recommendation = Recommendation.new(params[:recommendation])

    if @recommendation.save
      redirect_to([:admin, @recommendation], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @recommendation = Recommendation.find(params[:id])

    if @recommendation.update_attributes(params[:recommendation])
      redirect_to([:admin, @recommendation], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @recommendation = Recommendation.find(params[:id])
    @recommendation.destroy

    redirect_to(admin_recommendations_url)
  end

end
