class AddBibSeqToBrand < ActiveRecord::Migration
  def self.up
    add_column :brands, :bib_seq, :integer
    bib_seq = 10
    ['Vintage', 'Handmade', 'Small/Indie Brands'].each do |brand_name|
      brand = Brand.find_by_name(brand_name)
      unless brand
        brand = Brand.new(:name => brand_name)
      end
      brand.bib_seq = bib_seq
      brand.save
      bib_seq += 10
    end
  end

  def self.down
    remove_column :brands, :bib_seq
  end
end
