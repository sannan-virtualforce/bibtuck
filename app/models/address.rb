# == Schema Information
#
# Table name: addresses
#
#  id           :integer         not null, primary key
#  first_name   :string(255)
#  last_name    :string(255)
#  street_line1 :string(255)
#  street_line2 :string(255)
#  city         :string(255)
#  state        :string(255)
#  zipcode      :string(255)
#  phone        :string(255)
#  is_primary   :boolean         default(FALSE), not null
#  user_id      :integer         not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Address < ActiveRecord::Base
  validates_presence_of :first_name,
                        :last_name,
                        :street_line1,
                        :city,
                        :state,
                        :zipcode

  belongs_to :user
  has_many :shipping_box_deliveries, :dependent => :nullify

  scope :secondary, where(:is_primary => false)

  after_save :update_primary_address

  def full_name
    "#{first_name} #{last_name}"
  end

  def to_s
    "#{street_line1}#{street_line2.present? ? ' ' + street_line2 : ''}, #{city}, #{state} #{zipcode}"
  end

  def update_primary_address
    primary_count = Address.where(:user => user, :is_primary => true).count
    unless primary_count == 1
      if Address.where(:user => user).count == 1
        update_attribute :is_primary, true
      elsif is_primary
        Address.update_all('is_primary = false', :user => user, :id.ne => id)
      end
    end
  end

end
