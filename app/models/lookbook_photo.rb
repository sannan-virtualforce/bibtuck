# == Schema Information
# Schema version: 20120117211534
#
# Table name: lookbook_photos
#
#  id         :integer         not null, primary key
#  path       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class LookbookPhoto < ActiveRecord::Base
  mount_uploader :path, ImageUploader

  scope :for_homepage, limit(10).order(:created_at.desc)

  def external_link?
    (link && link =~ /(http|https):/) ? true : false
  end
end
