# == Schema Information
#
# Table name: follows
#
#  id           :integer         not null, primary key
#  follower_id  :integer         not null
#  following_id :integer         not null
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_follows_on_follower_id_and_following_id  (follower_id,following_id)
#

class Follow < ActiveRecord::Base
  attr_accessible :following_id

  belongs_to  :follower,
              :class_name     => 'User',
              :foreign_key    => :follower_id,
              :counter_cache  => :followings_count

  belongs_to  :following,
              :class_name     => 'User',
              :foreign_key    => :following_id,
              :counter_cache  => :followers_count

  has_many  :notifications_as_subject,
            :class_name   => 'Notification',
            :foreign_key  => :subject_id,
            :conditions   => { :subject_type => 'Follow' },
            :dependent    => :destroy

  has_many  :notifications_as_origin,
            :class_name   => 'Notification',
            :foreign_key  => :origin_id,
            :conditions   => { :origin_type => 'Follow' },
            :dependent    => :destroy

  validates_presence_of :follower_id,
                        :following_id

  scope :active, where(:follower => { :deactivated_at => nil }, :following => { :deactivated_at => nil }).joins(:follower, :following)

  # TODO ensure consistency with database constraint
  validates_uniqueness_of :following_id,
                          :scope => :follower_id

  validate :validate_follow

  def new_follower_subject
    [ follower.display_name,
      "is now following you"].join(' ')
  end

private

  def validate_follow
    return nil unless errors.empty?
    if follower == following
      errors.add(:follower_id, 'cannot follow self.')
    end
  end

end
