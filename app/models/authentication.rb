class Authentication < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :provider, :uid
  validates_uniqueness_of :uid, :scope => :provider
end
