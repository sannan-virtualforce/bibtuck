# == Schema Information
# Schema version: 20120203190133
#
# Table name: experiences
#
#  id         :integer         not null, primary key
#  comment    :text
#  rating     :integer
#  user_id    :integer
#  rater_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  item_id    :integer
#  response_1 :string(255)
#  response_2 :string(255)
#  response_3 :string(255)
#

class Experience < ActiveRecord::Base
  belongs_to :user
  belongs_to :rater, :class_name => "User", :foreign_key => "rater_id"
  belongs_to :item

  # Map field to the relevant question
  QUESTIONS = {
    :response_1 => "Did the item reflect what the seller described?",
    :response_2 => "Is this an exciting new addition to your closet?",
    :response_3 => "Would you buy from this seller again?"
  }

  validates_presence_of :rating

  after_create do |experience|
    Notification.create!(
      :template => 'rating',
      :user     => user,
      :subject  => self,
      :actor    => rater,
      :origin   => self
    )
  end
end
