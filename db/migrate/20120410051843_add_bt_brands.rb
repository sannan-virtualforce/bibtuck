class AddBtBrands < ActiveRecord::Migration
  def self.up
    Brand.create(:name => "Vintage")
    Brand.create(:name => "Handmade")
  end

  def self.down
  end
end
