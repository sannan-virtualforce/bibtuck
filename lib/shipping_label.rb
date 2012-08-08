# Placeholder wrapper to generate shipping
# labels using the Endicia API
#
module ShippingLabel
  TEST_MODE = true

  def self.get_label
    Endicia.get_label({
      :ToPostalCode => '06333', 
      :ToAddress1 => '15 Willow Lane', 
      :ToCity => 'East Lyme', 
      :ToState => 'CT', 
      :PartnerTransactionID => 1,  # order id or something
      :PartnerCustomerID => '666', 
      :MailClass => 'FIRST',
      :WeightOz => '2',
      :Test => 'YES',
      :RequesterID => 'ABCD',
      :AccountID => 123456, 
      :PassPhrase => 123456, 
      :FromCompany => 'Bibandtuck', 
      :ReturnAddress1 => '123 Fake Street', 
      :FromCity => 'New York', 
      :FromState => 'NY', 
      :FromPostalCode => '10011'
    })
  end
end
