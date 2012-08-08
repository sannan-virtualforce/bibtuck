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

require 'spec_helper'

describe Subscriber do
  pending "add some examples to (or delete) #{__FILE__}"
end
