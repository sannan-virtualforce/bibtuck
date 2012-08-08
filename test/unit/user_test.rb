# == Schema Information
# Schema version: 20120117211534
#
# Table name: users
#
#  id                              :integer         not null, primary key
#  email                           :string(255)     default(""), not null
#  encrypted_password              :string(128)     default("")
#  reset_password_token            :string(255)
#  remember_token                  :string(255)
#  remember_created_at             :datetime
#  sign_in_count                   :integer         default(0)
#  current_sign_in_at              :datetime
#  last_sign_in_at                 :datetime
#  current_sign_in_ip              :string(255)
#  last_sign_in_ip                 :string(255)
#  confirmation_token              :string(255)
#  confirmed_at                    :datetime
#  confirmation_sent_at            :datetime
#  failed_attempts                 :integer         default(0)
#  unlock_token                    :string(255)
#  locked_at                       :datetime
#  authentication_token            :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  admin                           :boolean         default(FALSE), not null
#  featured_at                     :datetime
#  first_name                      :string(255)
#  last_name                       :string(255)
#  username                        :string(255)
#  birthday                        :date
#  occupation                      :string(255)
#  about_me                        :text
#  website_url                     :string(255)
#  profile_picture                 :string(255)
#  invitation_token                :string(60)
#  invitation_sent_at              :datetime
#  invitation_limit                :integer
#  invited_by_id                   :integer
#  invited_by_type                 :string(255)
#  unread_notifications_count      :integer         default(0), not null
#  followers_count                 :integer         default(0), not null
#  followings_count                :integer         default(0), not null
#  hide_age                        :boolean         default(FALSE), not null
#  twitter_username                :string(255)
#  facebook_page                   :string(255)
#  send_new_follow_notification    :boolean         default(TRUE), not null
#  send_buck_purchase_notification :boolean         default(TRUE), not null
#  send_new_message_notification   :boolean         default(TRUE), not null
#  founding_member_at              :datetime
#  registration_code_id            :integer
#  featured_content                :text
#  top_rated_at                    :datetime
#  deactivated_at                  :datetime
#
# Indexes
#
#  index_users_on_admin                          (admin)
#  index_users_on_confirmation_token             (confirmation_token) UNIQUE
#  index_users_on_email                          (email) UNIQUE
#  index_users_on_invitation_token               (invitation_token)
#  index_users_on_invited_by_id                  (invited_by_id)
#  index_users_on_reset_password_token           (reset_password_token) UNIQUE
#  index_users_on_send_new_message_notification  (send_new_message_notification)
#  index_users_on_unlock_token                   (unlock_token) UNIQUE
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
