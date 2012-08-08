# == Schema Information
# Schema version: 20120203190133
#
# Table name: photos
#
#  id         :integer         not null, primary key
#  path       :string(255)
#  item_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#  bib_hash   :string(255)
#

class Photo < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  attr_accessor :curator

  mount_uploader :path, ImageUploader
  include Rails.application.routes.url_helpers

  scope :available, where(:item_id => nil)

  after_create { maybe_set_notification }

  def security_token
    Digest::SHA1.hexdigest(id.to_s + created_at.to_s)
  end

  def maybe_set_notification
    # Only set this if an admin puts in the
    # photo for the user.
    if curator.present?
      Notification.create!(
        :template => 'added_photo',
        :user     => user,
        :subject  => self,
        :actor    => curator,
        :origin   => self
      )
    end
  end

  # TODO make this async
  def fetch!(url, key)

    return nil unless key == security_token

    make_temp_path

    self.remove_path!
    self.remote_path_url = url

    if save
      reload
    end
    self
  end

  def self.recreate_versions!
    find_each { |p| p.path.recreate_versions! }
  end

  def to_jq_upload
  {
    "photo_id" => id,
    "name" => read_attribute(:path),
    "size" => path.size,
    "url" => path.url,
    "full_url" => "#{root_url}#{path.url.to_s[1, path.url.length - 1]}",
    "thumbnail_url" => path.thumb.url,
    "delete_url" => photo_path(:id => id),
    "delete_type" => "DELETE",
    "is_primary" => is_primary,
    "post_url" => aviary_callback_photo_url(id, :k => security_token)
  }
  end

private

  def make_temp_path
    FileUtils.mkdir_p(temp_path)
  end

  def temp_path
    File.join(Rails.root,
              'public',
              'system',
              'uploads',
              'photo',
              'tmp',
              id.to_s)
  end

end
