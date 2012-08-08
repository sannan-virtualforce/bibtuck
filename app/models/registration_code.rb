# == Schema Information
# Schema version: 20120117211534
#
# Table name: registration_codes
#
#  id                 :integer         not null, primary key
#  code               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  registration_limit :integer
#

class RegistrationCode < ActiveRecord::Base
  validates_presence_of  :code
  validates_uniqueness_of :code, :case_sensitive => false

  has_many :users

  def can_use?
    return true if !registration_limit
    remaining_count > 0
  end

  def remaining_count
    registration_limit - users.count
  end

  def used_count
    users.count
  end
end
