Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '252854674826204', '9e1858cde1c7ec74783caa541ca1aaa2'
end
