class SearchController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def create
    fetch_search_results
  end
end
