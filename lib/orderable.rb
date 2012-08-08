module Orderable
  # Child model must define the after_purchase callback
  def purchase
    res = process_purchase 
    logger.debug res
    self.response = res.params.to_yaml
    self.save
    after_purchase if res.success?
  end

  def express_token=(token)
    write_attribute(:express_token, token)
    if new_record? && !token.blank?
      details = EXPRESS_GATEWAY.details_for(token)
      self.express_payer_id = details.payer_id
      self.first_name ||= details.params["first_name"]
      self.last_name ||= details.params["last_name"]
    end
  end

  private

  def express_purchase_options
    {
      :ip => ip_address,
      :token => express_token,
      :payer_id => express_payer_id
    }
  end

  def process_purchase
    EXPRESS_GATEWAY.purchase(amount_in_cents, express_purchase_options)
  end
end
