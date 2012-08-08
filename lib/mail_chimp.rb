class MailChimp
  API_KEY = "b09dd1960304ae0e88135864dd375a41-us2"
  MASTER_LIST_ID = '69f3cebd5b'

  Gibbon.api_key = API_KEY

  def self.enabled?
    !Rails.env.development?
  end

  def self.sync_user(user)
    return false if !enabled?

    Gibbon.listSubscribe({
      :email_address => user.email,
      :double_optin => false,
      :id => MASTER_LIST_ID
    })
  end
end
