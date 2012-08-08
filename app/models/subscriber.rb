# == Schema Information
#
# Table name: subscribers
#
#  id              :integer         not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  email           :string(255)     not null
#  url             :string(255)
#  occupation      :string(255)
#  favorite_period :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Subscriber < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :occupation
end
