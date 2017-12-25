Rails.application.config.middleware.use OmniAuth::Builder do
  
  provider :google_oauth2, OMNIAUTH_KEYS["google_token"], OMNIAUTH_KEYS["google_secret"], {
    image_aspect_ratio: "original",
    access_type: "offline",
    prompt: "select_account"
  }
  provider :linkedin,OMNIAUTH_KEYS["linkedin_token"] ,OMNIAUTH_KEYS["linkedin_secret"] , {
      :scope => 'r_basicprofile w_share rw_company_admin',
      :authorize_params => {
          :state => SecureRandom.hex(24),
          :redirect_uri => "#{ENV['CALLBACK_HOST']}/users/auth/linkedin/callback"
      }
  }
  provider :twitter, OMNIAUTH_KEYS["tw_client_id"], OMNIAUTH_KEYS["tw_client_secret"],{
      :secure_image_url => 'true',
      :image_size => 'original',
      :authorize_params => {
          :force_login => 'true',
          :lang => 'en'
      }
  }
  provider :facebook, OMNIAUTH_KEYS["fb_client_id"], OMNIAUTH_KEYS["fb_client_secret"],{
      :scope => 'publish_actions,email,user_birthday,user_location,user_status,user_photos,user_posts,manage_pages,read_insights,ads_management,ads_read',
      :display => 'page',
      :image_size => "600x400",
      :client_options => {:ssl => {:ca_path => "/usr/lib/ssl/certs/ca-certificates.crt"}}
  }
end

OmniAuth.config.on_failure do |env|
  message_key = env['omniauth.error.type']
  error = env['omniauth.error'].error
  error_reason = env['omniauth.error'].error_reason
  [302, { Location => '/', Content-Type => "text/html", Error => "#{message_key} #{error} #{error_reason}" }.stringify_keys!, []]
end