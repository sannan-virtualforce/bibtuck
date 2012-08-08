# == Schema Information
#
# Table name: notifications
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  body         :text
#  subject_type :string(255)
#  subject_id   :integer
#  viewed_at    :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  actor_type   :string(255)
#  actor_id     :integer
#  origin_type  :string(255)
#  origin_id    :integer
#  template     :string(255)
#

require 'spec_helper'

describe Notification do
  before do
  end

  it do
    Notification.new.create!
  end
end
