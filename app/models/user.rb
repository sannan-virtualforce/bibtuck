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

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
          :invitable,
          :trackable,
          :validatable

  MAXIMUM_ABOUT_ME_LENGTH = 160
  MAXIMUM_USERNAME_LENGTH = 11

  belongs_to :registration_code

  validates_presence_of :email
  validates_presence_of :username, :unless => :invitation?
  validates_presence_of :first_name, :unless => :invitation?
  validates_presence_of :last_name, :unless => :invitation?

  validates_uniqueness_of :email

  validates_uniqueness_of :username,
                          :unless => :invitation?

  validates_length_of :about_me, :maximum => MAXIMUM_ABOUT_ME_LENGTH, :allow_blank => true
  validates_length_of :username, :maximum => MAXIMUM_USERNAME_LENGTH

  has_many :shipping_addresses,
    :class_name => 'Address',
    :order => 'created_at DESC'

  has_many :invitees,
    :class_name => 'User',
    :foreign_key => :invited_by_id
  has_many :credits
  has_many :authentications, :dependent => :destroy

  has_one :primary_shipping_address,
          :class_name => 'Address',
          :conditions => 'is_primary is true'

  has_many :user_conversations
  has_many :conversations, :through => :user_conversations
  has_many :messages, :through => :conversations
  has_many :shipping_box_deliveries, :dependent => :destroy

  accepts_nested_attributes_for :shipping_addresses, :primary_shipping_address

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :password,
                  :password_confirmation,
                  :remember_me,
                  :shipping_address_attributes,
                  :items,
                  :founding_member,
                  :invite_name,
                  :currently_featured,
                  :founding_member_at,
                  :featured,
                  :featured_at,
                  :top_rated,
                  :top_rated_at,
                  :profile_picture,
                  :registration_code_id,
                  :invitation_limit,
                  :twitter_username,
                  :featured_content,
                  :primary_shipping_address_attributes,
                  :facebook_page,
                  :first_name,
                  :last_name,
                  :username,
                  :birthday,
                  :occupation,
                  :current_city,
                  :hide_age,
                  :about_me,
                  :tos_agreed_at,
                  :website_url,
                  :followings,
                  :follow,
                  :custom_message,
                  :send_new_follow_notification,
                  :send_buck_purchase_notification

  has_many :items, :dependent => :destroy
  has_many :buck_refunds
  has_many :order_items, :through => :orders
  has_many :orders, :dependent => :destroy
  has_many :photos

  has_many  :following_follows,
            :class_name   => "Follow",
            :foreign_key  => :follower_id,
            :dependent    => :destroy

  has_many  :followings,
            :through      => :following_follows,
            :source       => :following

  has_many  :follower_follows,
            :class_name   => "Follow",
            :foreign_key  => :following_id,
            :dependent    => :destroy

  has_many  :followers,
            :through      => :follower_follows#,
 #           :source       => :follower

  has_many :buck_purchases
  has_many :buck_transactions
  has_many :experiences, :order => 'created_at DESC'
  has_many :notifications, :dependent => :destroy

  mount_uploader :profile_picture, ImageUploader

  scope :top_rated, where("deactivated_at IS NULL AND top_rated_at IS NOT NULL").order("top_rated_at DESC")
  scope :featured, where("deactivated_at IS NULL AND featured_at IS NOT NULL").order("featured_at DESC")
  scope :registred, where("deactivated_at IS NULL AND last_sign_in_at IS NOT NULL")
  scope :active, :conditions => { :deactivated_at => nil }

  def self.admin
    User.where(:email => 'info@bibandtuck.com').first
  end

  after_initialize do |user|
    user.custom_message ||= "Join Bib + Tuck!"
  end

  before_create do |user|
    user.invitation_limit = User.invitation_limit
  end

  after_update do |user|
    if user.currently_featured_changed?
      if user.currently_featured?
        User.where('id != ?', user.id).map { |u| u.update_attribute(:currently_featured, false) }
      end
    end
  end

  before_validation do |user|
    if user.website_url.present?
      user.website_url = user.website_url[/^http/] ? user.website_url : 'http://' + user.website_url
    end
    true
  end

  def tucked_items
    Item.joins(:order_item, :order).where(:order => {:user_id => id})
  end

  def follow(user)
    following_follows.create(:following_id => user.id)
  end

  # For use with saved photos to group them
  def photo_hash
    Digest::MD5.hexdigest(Time.now.to_s + email)
  end

  # Used during registration to accept the address.
  # Custom setter because we do not want to ask for
  # the same field twice (first_name and last_name)
  #
  def primary_shipping_address_attributes=(attrs)
    attrs[:first_name] = first_name if attrs[:first_name].blank?
    attrs[:last_name] = last_name if attrs[:last_name].blank?
    addr = Address.new(attrs)
    if addr.valid?
      self.primary_shipping_address = addr
    end
  end

  def full_name
    [first_name, last_name].compact.reject(&:empty?).join(' ')
  end

  def name
    "#{first_name} #{last_name[0]}"
  end

  def display_name
    [:full_name, :name, :username, :email].each do |attr|
      return send(attr) if !send(attr).blank?
    end
  end

  def age
    if birthday
      now = Time.now.utc.to_date
      now.year - birthday.year -
        ((now.month > birthday.month ||
          (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
    end
  end

  def process_invite!
    self.class.transaction do
      Notification.create(
        :template => 'invitation',
        :user     => invited_by,
        :subject  => self,
        :actor    => invited_by,
        :origin   => self
      )
      BuckTransaction.create(
        :user => invited_by,
        :reason => :invitation,
        :reference => self,
        :delta => BuckTransaction::POINTS[:invitation]
      )
      MailChimp.sync_user(self)
    end
    self.process_registration!
  end

  def process_registration!
    self.class.transaction do
      Notification.create(
        :template => 'new_user',
        :user     => self,
        :subject  => self,
        :actor    => self,
        :origin   => self
      )
      BuckTransaction.create(
        :user => self,
        :reason => :new_user,
        :reference => self,
        :delta => BuckTransaction::POINTS[:new_user]
      )
      MailChimp.sync_user(self)
    end
  end

  def average_rating
    experiences.sum(:rating).to_f / experiences.count.to_f if experiences.any?
  end

  def follows(user)
    following_follows.find_by_following_id(user.id)
  end

  def buck_balance
    buck_transactions.map(&:delta).sum
  end

  # TODO figure out a better way to manage invitations
  def invitation?
    invitation_token &&
    password.nil? &&
    (encrypted_password.nil? || encrypted_password.empty?)
  end

  def invites_left?
    return false if invitation_limit.blank?
    invitation_limit > 0
  end

  def founding_member
    !!founding_member_at
  end
  alias :founding_member? :founding_member

  def founding_member=(checked)
    if checked == "1" && founding_member_at.blank?
      touch(:founding_member_at)

      if !Notification.where(:user => self, :template => 'founding_member').exists?
        Notification.create!(
          :template => 'founding_member',
          :user     => self,
          :subject  => self,
          :actor    => self,
          :origin   => self
        )
      end
    else
      update_attribute(:founding_member_at, nil)
    end
  end

  def featured
    !!featured_at
  end
  alias :featured? :featured

  def featured=(checked)
    checked == "1" ? touch(:featured_at) : update_attribute(:featured_at, nil)
  end

  def top_rated
    !!top_rated_at
  end
  alias :top_rated? :top_rated

  def top_rated=(checked)
    checked == "1" ? touch(:top_rated_at) : update_attribute(:top_rated_at, nil)
  end

  def location
    current_city || (primary_shipping_address.blank? ? nil : "#{primary_shipping_address.city}, #{primary_shipping_address.state}")
  end

  def deactivate!
    touch(:deactivated_at)
  end

  def short_bio
    [ (age.present? && !hide_age ?
        (occupation.present? ?
          "#{age} year old" : (location.present? ? "#{age} years old," : "#{age} years old")
        ) : nil
      ),
      (occupation.present? ? occupation.html_safe : nil),
      (location.present? ? "living in #{location.html_safe}" : nil)
    ].compact.join(' ')
  end

  def deactivated?
    !!deactivated_at
  end

  def can_rate?(item)
    !Experience.where(:user_id => item.user.id, :item_id => item.id).exists?
  end

  def can_invite?
    invitation_limit.to_i > 0
  end

  def can_modify?(object)
    object && object.user && object.user == self
  end

  def can_afford?(item)
    item.price.to_i <= buck_balance
  end

  def can_purchase?(item)
    item.user != self && !item.tucked?
  end

  def pretty_website_url
    website_url.sub('http://', '')
  end

  # Users you follow together
  def follows_with(user)
    user.followings & followings
  end

  # Users that follow this user, that you are following
  def second_degree_followers(user)
    user.followers & followings
  end

  def convo_with(user2)
    user_conversations.select { |uc|
      uc.users.member?(self) && uc.users.member?(user2)
    }.first
  end

  def shipping_box_amount_delivered(box_size)
    delivery = shipping_box_deliveries.find_by_box_size(box_size)
    if delivery
      return delivery.amount
    end
    return 0
  end
end
