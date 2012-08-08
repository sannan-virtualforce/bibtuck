class OrderItem < ActiveRecord::Base

  @@shipping_labels_path = nil

  belongs_to :item
  belongs_to :order

  has_one :seller, :through => :item, :source => :user
  has_one :buyer, :through => :order, :source => :user

  validates :item, :presence => true
  validates :order, :presence => true
  validates :from_addr_first_name, :presence => true
  validates :from_addr_last_name, :presence => true
  validates :from_addr_street_line1, :presence => true
  validates :from_addr_city, :presence => true
  validates :from_addr_state, :presence => true
  validates :from_addr_zipcode, :presence => true

  state_machine :shipping_status, :initial => :pending do
    state :pending
    state :shipped
    state :delivered
    state :canceled

    event :mark_as_shipped do
      transition :pending => :shipped
    end

    event :mark_as_delivered do
      transition [:pending, :shipped] => :delivered
    end

    event :mark_as_canceled do
      transition [:pending, :shipped] => :canceled
    end

    after_transition any => :shipped do |order_item, transition|
      order_item.touch :shipped_at
      Notification.create!(
        :template => 'shipped_item',
        :user => order_item.order.user,
        :subject => order_item.item,
        :actor => order_item.seller,
        :origin => order_item
      )
      Notifier.shipped_item(order_item).deliver
    end

    after_transition any => :delivered do |order_item, transition|
      order_item.touch :delivered_at
      Notification.create!(
        :template => 'delivered_item',
        :user => order_item.order.user,
        :subject => order_item.item,
        :actor => order_item.seller,
        :origin => order_item
      )
    end

    after_transition any => :canceled do |order_item, transition|
      order_item.touch :delivered_at
      order_item.item.mark_as_complete
    end
  end

  def from_addr=(address)
    %w(first_name last_name street_line1 street_line2 city state zipcode phone).each do |attr|
      write_attribute "from_addr_#{attr}", address.try(attr)
    end
  end

  def from_addr
    address = Address.new
    %w(first_name last_name street_line1 street_line2 city state zipcode phone).each do |attr|
      address[attr] = read_attribute("from_addr_#{attr}")
    end
    return address
  end

  def tracked?
    tracking_number.present?
  end

  def tracking_url
    "https://tools.usps.com/go/TrackConfirmAction?tLabels=" + tracking_number
  end

  def shipping_status_message
    if shipped? || delivered?
      last_shipping_status_message
    else
      "The seller has been notified of your purchase but your item has not been shipped."
    end
  end

  def check_for_shipping_status_update!
    return unless tracked? || shipped? || pending?
    response = Endicia.status_request(tracking_number)
    if response[:success] && response[:response_body] =~ /<StatusCode>(.+?)</
      status_code = $1
      case status_code
      when 'D'
        mark_as_delivered
      when 'I', 'L', 'F', 'R', 'U'
        mark_as_shipped
      end
      update_attribute :last_shipping_status_message, "#{response[:status]} (Status Code: #{status_code})"
    end
  end

  def generate_shipping_label!(generate_new)
    if !shipping_label.present? || generate_new
      label = Endicia.get_label(
        :ToName => "#{order.to_addr_first_name} #{order.to_addr_last_name}",
        :ToPostalCode => order.to_addr_zipcode,
        :ToAddress1 => order.to_addr_street_line1,
        :ToAddress2 => order.to_addr_street_line2,
        :ToCity => order.to_addr_city,
        :ToState => order.to_addr_state,
        :ToPostalCode => order.to_addr_zipcode,
        :PartnerTransactionID => item.id,
        :PartnerCustomerID => order.user_id,
        :ReturnAddress1 => from_addr_street_line1,
        :ReturnAddress2 => from_addr_street_line2,
        :FromName => "#{from_addr_first_name} #{from_addr_last_name}",
        :FromCity => from_addr_city,
        :FromState => from_addr_state,
        :FromPostalCode => from_addr_zipcode,
        :MailClass => 'Priority',
        :WeightOz => 1,
        :ImageFormat => 'PDF',
        :LabelSize => '4x6',
        :ImageResolution => '300',
        :ImageRotation => 'None',
        :MailPieceShape => Category::BOX_SIZES_ENDICIA[item.shipping_box_size]
      )
      if label.status == '0'
        self.tracking_number = label.tracking_number
        shipping_label_filename = "#{id.to_s}.pdf"
        File.open(File.join(OrderItem.shipping_labels_path, shipping_label_filename), 'wb') do |file|
          file << Base64.decode64(label.image)
        end
        self.shipping_label = shipping_label_filename
        self.last_shipping_status_message = nil
        self.save
        return true
      else
        update_attribute :last_shipping_status_message, "There was an error generating shipping label:<br/>" + label.error_message
        return false
      end
    end
    return true
  end

  def self.shipping_labels_path
    unless @@shipping_labels_path
      @@shipping_labels_path = File.join(Rails.root, 'public', 'system', 'uploads', 'shipping_labels')
      FileUtils.mkdir_p @@shipping_labels_path
    end
    return @@shipping_labels_path
  end

  def notify_seller_if_needed
    if order.created_at < 10.days.ago
      if seller_notified_to_ship < 2
        Notifier.notify_seller_to_ship(item.id).deliver
        update_attribute :seller_notified_to_ship, 2
      end
    elsif order.created_at < 5.days.ago
      if seller_notified_to_ship < 1
        Notifier.notify_seller_to_ship(item.id).deliver
        update_attribute :seller_notified_to_ship, 1
      end
    end
  end

end
