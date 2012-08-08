# == Schema Information
# Schema version: 20120117211534
#
# Table name: items
#
#  id                          :integer         not null, primary key
#  name                        :string(255)
#  condition                   :string(255)
#  size                        :string(255)
#  brand_id                    :integer
#  user_id                     :integer
#  fit                         :string(255)
#  color                       :string(255)
#  description                 :text
#  why_sell                    :text
#  price                       :float
#  bibbed_at                   :datetime
#  created_at                  :datetime
#  updated_at                  :datetime
#  editors_pick                :boolean
#  order_id                    :integer
#  shipping_box_size           :string(255)
#  shipping_from_address_id    :integer
#  tucked_at                   :datetime
#  tracking_number             :string(255)
#  carrier_pickup_date         :date
#  carrier_pickup_confirmation :string(255)
#  state                       :string(255)
#  carrier_pickup_location     :string(255)
#  category_id                 :integer
#

class Item < ActiveRecord::Base

  CONDITIONS  = [ 'Like New',
                  'Excellent Condition',
                  'Good Condition',
                  'Poor Condition' ]


  FITS        = [ 'True to Size',
                  'Runs Small',
                  'Runs Big',
                  'n/a' ]

  CARRIER_PICKUP_LOCATIONS = {
    'Side Door'               => :sd,
    'Knock on Door/Ring Bell' => :kd,
    'Mail Room'               => :mr,
    'Office'                  => :of,
    'Reception'               => :rc,
    'In/At Mailbox'           => :im,
    'Other'                   => :ot,
    'Front Door'              => :fd,
    'Back Door'               => :bd,
  }

  after_initialize :init

  belongs_to :brand
  belongs_to :user
  belongs_to :category
  belongs_to :shipping_address, :foreign_key => 'shipping_from_address_id'

  belongs_to :shipping_from_address, :class_name => 'Address'

  has_many :photos, :dependent => :destroy

  accepts_nested_attributes_for :photos,
    :allow_destroy  => true,
    :reject_if      => proc { |attributes| attributes['path'].blank? }

  has_one :flagged_item
  has_one :buck_refund
  has_one :experience
  has_one :order_item
  has_one :order, :through => :order_item
  has_one :cart_item, :dependent => :destroy

  validates_presence_of :name,
                        :category,
                        :size,
                        :price,
                        :brand,
                        :photos,
                        :condition,
                        :description,
                        :shipping_from_address
  validates_presence_of :fit, :if => :requires_fit?

  validates_numericality_of :price, :greater_than => 0, :allow_nil => true
  validates :shipping_box_size, :inclusion => {:in => Category::BOX_SIZES_ENDICIA.keys, :message => "%{value} is not a valid box size"}

  scope :active, where(:user => { :deactivated_at => nil }).joins(:user)
  scope :bibbed, where(:bibbed_at.ne => nil).order(:bibbed_at.desc)
  scope :for_sale, bibbed & joins('LEFT OUTER JOIN order_items ON items.id = order_items.item_id').where(:order_items => {:id => nil}).order(:tucked_at.desc)
  scope :sold, joins('LEFT OUTER JOIN order_items ON items.id = order_items.item_id').where(:order_items => {:id.ne => nil}, :tucked_at.ne => nil)
  scope :older_than, lambda { |ts|
    ts ? where('bibbed_at < ?', ts) : nil
  }
  scope :unlisted, where(:bibbed_at => nil)
  scope :filtered_by, lambda { |filter, user|
    case filter
    when 'editors_picks'
      where(:editors_pick => true)
    when 'top_rated'
      joins(:user).where('top_rated_at is not null')
    when 'following'
      joins(:user => :followers).where('follower_id = ?', user.id)
    end
  }
  scope :sorted_by, lambda { |sorter|
    case sorter
    when 'bucks_asc'
      order(:price.asc)
    when 'bucks_desc'
      order(:price.desc)
    else
      bibbed
    end
  }
  scope :with_size, lambda { |size| size.present? ? where(:size => size) : nil }

  attr_accessor :new_brand,
                :color_1,
                :color_2,
                :color_3,
                :color_4,
                :color_5

  delegate :name, :to         => :category,
                  :prefix     => true,
                  :allow_nil  => true

  delegate :username, :to         => :user,
                      :allow_nil  => true

  state_machine :initial => :open do
    state :open
    state :listed
    state :shipping
    state :complete

    event :mark_as_open do
      transition :listed => :open
    end

    event :mark_as_listed do
      transition :open => :listed
    end

    event :mark_as_shipping do
      transition :listed => :shipping, :if => lambda { |item| item.order_item.present? }
    end

    event :mark_as_complete do
      transition :shipping => :complete
    end
  end

  paginates_per 10
  is_impressionable

  after_save do |item|
    self.update_counter_cache
  end

  after_destroy do |item|
    self.update_counter_cache
  end

  after_update :notify_editors_picks

  def init
    @colors = attributes['color'] ? attributes['color'].split : []
  end

  def requires_fit?
    category.blank? || category.try(:name) != 'accessories'
  end

  def transaction_fee_in_cents
    Order::TRANSACTION_FEE_IN_CENTS
  end

  def shipping_fee_in_cents
    category.shipping_fee
  end

  def total_fee_in_cents
    transaction_fee_in_cents + shipping_fee_in_cents
  end

  def total_fee
    total_fee_in_cents / 100
  end

  def tuck!(order)
    Item.transaction do
      self.attributes = {
        :tucked_at => Time.now,
        :order => order
      }
      mark_as_shipping

      BuckTransaction.create(:user => user,
                             :reason => :tuck_seller,
                             :reference => order,
                             :delta => price)

      Notification.create!(
        :template => 'tucked_seller',
        :user     => user,
        :subject  => self,
        :actor    => user,
        :origin   => self
      )
      save!(false)
    end
  end

  def bib
    return false if photos.count < 1
    update_attribute(:bibbed_at, Time.now)
    mark_as_listed
  end

  def unbib!
    update_attribute(:bibbed_at, nil)
    mark_as_open
  end

  def rated?
    experience.present?
  end

  def primary_photo
    primary = photos.where(:is_primary => true).first
    unless primary
      primary = photos.first
    end
    return primary
  end

  def carrier_pickup?
    carrier_pickup_location && carrier_pickup_date && carrier_pickup_confirmation
  end

  def request_carrier_pickup!
    carrier_pickup_opts = {
      :FirstName      => order.to_addr_first_name,
      :LastName       => order.to_addr_last_name,
      :Address        => order.to_addr_street_line1,
      :SuiteOrApt     => order.to_addr_street_line2,
      :City           => order.to_addr_city,
      :State          => order.to_addr_state,
      :ZIP5           => order.to_addr_zipcode,
      :Phone          => order.to_addr_phone,
      :MailPieceShape => Category::BOX_SIZES_ENDICIA[shipping_box_size]
    }

    response = Endicia.carrier_pickup_request(tracking_number,
                                              carrier_pickup_code,
                                              carrier_pickup_opts)

    if response[:success]
      self.attributes = {
        :carrier_pickup_date         => Date.strptime(response[:date], "%m/%d/%Y"),
        :carrier_pickup_confirmation => response[:confirmation_number]
      }
      save!
    else
      raise "ERROR SCHEDULING PICKUP: #{response.inspect}"
    end
  end

  def flagged?
    !!flagged_item
  end

  def tucked?
    !!order_item && tucked_at?
  end

  def carrier_pickup_code
    CARRIER_PICKUP_LOCATIONS.invert[carrier_pickup_location]
  end

  def brand_name
    brand ? brand.name : ''
  end

  def new_brand=(string)
    return nil unless string.present?
    nb = Brand.where('lower(name) = ?', string.strip.downcase).first
    unless nb
      nb = Brand.create(:name => string)
    end
    self.brand = nb
  end

  # color #FFFFFE is "blank" color
  def filter_color(col)
    col =~ /transparent|false/i ? nil : col
  end

  def update_color
    self.color = @colors.compact.join(' ')
  end

  def colors
    @colors
  end

  def color_1=(string)
    @colors ||= []
    @colors[0] = filter_color string
    update_color
  end

  def color_2=(string)
    @colors ||= []
    @colors[1] = filter_color string
    update_color
  end

  def color_3=(string)
    @colors ||= []
    @colors[2] = filter_color string
    update_color
  end

  def color_4=(string)
    @colors ||= []
    @colors[3] = filter_color string
    update_color
  end

  def color_5=(string)
    @colors ||= []
    @colors[4] = filter_color string
    update_color
  end

  def color_1
    @colors[0]
  end

  def color_2
    @colors[1]
  end

  def color_3
    @colors[2]
  end
  
  def color_4
    @colors[3]
  end

  def color_5
    @colors[4]
  end

  def recommended_items(user_to_recommend_to)
    return [] if user_to_recommend_to.blank?

    recommendations = []

    [:user, :category, :brand].shuffle.each do |assoc|
      relation = send(assoc)
      if relation.present?
        recommendations += relation.items.active
          .bibbed.joins('LEFT OUTER JOIN order_items on items.id = order_items.item_id')
          .where(:order_items => {:id => nil}, :id.ne => id, :tucked_at => nil, :user_id.ne => user_to_recommend_to.id)
          .limit(6)
          .order('random()')
      end
    end

    recommendations += Item.active.bibbed.where(:size => size).where('items.id != ?', id).limit(3)
    recommendations.uniq.shuffle.first(3)
  end

  def can_modify_list_status?
    listed? || open?
  end

  def can_ship?(user)
    shipping? && order_item.pending? && user == self.user
  end

  def can_request_refund?
    (complete? || (shipping? && tucked_at <= 10.days.ago)) && (order_item.try(:delivered_at) ? order_item.delivered_at > 30.days.ago : true)
  end

  def update_counter_cache
    self.user.bibbed_items_count = Item.count(:conditions => ["user_id = ? and bibbed_at is not null", self.user.id])
    self.user.save
  end

  def notify_editors_picks
    if editors_pick_changed? && editors_pick
      Notifier.editors_pick(self.id).deliver
    end
  end

  def update_primary_photo(photo_id = nil)
    primary_id = photo_id.to_i
    if primary_id > 0
      photos.each do |photo|
        if photo.id == primary_id
          photo.update_attribute(:is_primary, true) unless photo.is_primary
        else
          photo.update_attribute(:is_primary, nil) if photo.is_primary
        end
      end
    else
      marked_first = false
      photos.each do |photo|
        unless marked_first
          photo.update_attribute(:is_primary, true) unless photo.is_primary
          marked_first = true
        else
          photo.update_attribute(:is_primary, nil) if photo.is_primary
        end
      end
    end
  end

  def view_count_total
    self.impressionist_count
  end

  def view_count_distinct_user
    self.impressionist_count(:filter => :user_id)
  end

  def view_count_session
    self.impressionist_count(:filter => :session_hash)
  end

  def view_count_session_qv
    Impression.where(:impressionable_type => 'Item', :impressionable_id => id, :action_name => 'quick_view').count('distinct session_hash')
  end

  def view_count_total_qv
    Impression.where(:impressionable_type => 'Item', :impressionable_id => id, :action_name => 'quick_view').count
  end

end
