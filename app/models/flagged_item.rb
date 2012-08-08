# == Schema Information
#
# Table name: flagged_items
#
#  id         :integer         not null, primary key
#  item_id    :integer
#  user_id    :integer
#  comment    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class FlaggedItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :item

  validates_presence_of :comment

  delegate :name, :to         => :item,
                  :prefix     => true,
                  :allow_nil  => true

  delegate :username, :to         => :user,
                      :allow_nil  => true

  after_create do
    Notifier.flagged_item(self).deliver!
  end
end
