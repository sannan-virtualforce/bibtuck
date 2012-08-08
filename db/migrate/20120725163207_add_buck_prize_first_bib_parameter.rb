class AddBuckPrizeFirstBibParameter < ActiveRecord::Migration
  def self.up
    Parameter.create(
      :key => 'buck_prize_first_bib',
      :description => 'Amount of bucks user gets for bibbig his first item. Clear or set to 0 to turn off.',
      :value => 10,
      :content_type => 'number'
    )
  end

  def self.down
    Parameter.find_by_key(:buck_prize_first_bib).try(:destroy)
  end
end
