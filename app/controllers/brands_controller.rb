class BrandsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @brands_with_headers = {}

    Brand.by_name.each do |brand|
      if brand.name =~ /^\d/
        section = '123'
      else
        section = brand.name.first.downcase
      end
      @brands_with_headers[section] ||= Set.new
      @brands_with_headers[section] << brand
    end
    @columns = distribute_into_columns_ordered(@brands_with_headers.keys, 4) do |section|
      @brands_with_headers[section].length + 2
    end
  end
end
