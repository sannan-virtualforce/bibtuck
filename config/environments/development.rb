Bibtuck::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes                          = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils                             = true

  # Show full error reports and disable caching
  config.consider_all_requests_local            = true
  config.action_view.debug_rjs                  = true
  config.action_controller.perform_caching      = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors    = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation             = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  Rails.application.routes.default_url_options[:host]= 'localhost:3000'
  config.action_mailer.default_url_options           = { :host => 'localhost:3000' }

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  #config.action_mailer.delivery_method = :file

  APP_BUCKET                               = "bibtuck-development"

  require 'tlsmail'
  Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
  ActionMailer::Base.delivery_method       = :smtp
  ActionMailer::Base.perform_deliveries    = true
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings         = {
      :address              => "smtp.gmail.com",
      :port                 => "587",
      :domain               => "gmail.com",
      :enable_starttls_auto => true,
      :authentication       => :login,
      :user_name            => "virtual.force.test@gmail.com",
      :password             => "virtualforce-123"
  }

  config.action_mailer.raise_delivery_errors = true

end

# PayPal Info
paypal_options                     = {
    :login     => 'biband_1311654084_biz_api1.gmail.com',
    :password  => '1311654122',
    :signature => 'ATbbN-To0djUV3Yu4QtudIVQtYgPACjtyeVMgndCsty8-sQdr9kBrhww'
}
ActiveMerchant::Billing::Base.mode = :test
EXPRESS_GATEWAY                    = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)

# WePay Info
WEPAY_OPTIONS                      = {
    :client_id    => '174661',
    :secret       => '91de865ed2',
    :access_token => 'd132c3b164d2a73c5ddfb8e59498914845f16023c6a29b2d5b15007ace7166c0',
    :account_id   => '1955594',
    :use_stage    => true
}
