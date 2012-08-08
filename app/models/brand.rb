# == Schema Information
#
# Table name: brands
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Brand < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :case_insensitive => false
  has_many :items

  scope :by_name, order('name asc')
  scope :active,
    select('brands.id, brands.name, count(*)').
    joins(:items).
    joins('LEFT OUTER JOIN order_items ON items.id = order_items.item_id').
    where(:items => {:bibbed_at.ne => nil}, :order_items => {:id => nil}).
    group('brands.id, brands.name').
    order('count(*) desc').
    limit(5)

end
