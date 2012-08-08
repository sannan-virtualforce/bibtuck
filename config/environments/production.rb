Bibtuck::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  Rails.application.routes.default_url_options[:host]= 'bibandtuck.com'
  config.action_mailer.default_url_options = { :host => 'bibandtuck.com' }
  #config.action_mailer.delivery_method = :smtp
  config.action_mailer.delivery_method = :sendmail

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  APP_BUCKET = "bibtuck-production"

  config.action_controller.asset_host = Proc.new do |source, request|
    if source == true or request == false
      nil
    else
      if request.ssl?
        "cdn-ssl.bibandtuck.com"
      else
        "cdn.bibandtuck.com"
      end
    end
  end
end

Bibtuck::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[BIBANDTUCK] ",
  :sender_address => %{"notifier" <notifier@bibandtuck.com>},
  :exception_recipients => %w{igor.kovacevic@gmail.com}

# PayPal info
paypal_options = {
  :login => 'paypal_api1.bibandtuck.com',
  :password => '5XEBEAGC6LJXJVAV',
  :signature => 'A6tszZK1lKIH1gg20a5Xq79a9dH6A5A4p37cYbQdGY.bkZdE2efz-7Wu'
}
ActiveMerchant::Billing::Base.mode = :production
EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)

# WePay Info
WEPAY_OPTIONS = {
  :client_id => '158608',
  :secret => '782dd5fc9c',
  :access_token => 'f3d8e2f80e9a0dbcb406c5aad48a43af81095f3a0db37b426a34e08235c023fe',
  :account_id => '1598713',
  :use_stage => false
}
