#CarrierWave.configure do |config|
#  config.root = Rails.root.join('tmp')
#  config.cache_dir = 'carrierwave'
#
#  config.fog_credentials = {
#    :provider               => 'AWS',       # required
#    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],       # required
#    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
#  }
#  config.fog_directory  = APP_BUCKET                     # required
#  # config.fog_host       = 'https://assets.example.com'            # optional, defaults to nil
#  # config.fog_public     = false                                   # optional, defaults to true
#  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
#end
