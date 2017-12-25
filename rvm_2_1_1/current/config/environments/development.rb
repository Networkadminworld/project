require "mandrill_logger"
require "gupshup_logger"
require "gcm_logger"
InquirlyNew::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = false

  #config.middleware.use "CustomDomainCookie", ENV["DOMAIN"]
  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true
  #config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    #  Bullet.growl = true
    #Bullet.rails_logger = true
  #end
  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.middleware.delete Rack::Lock

  config.action_mailer.smtp_settings = {
    :address   => 'smtp.mandrillapp.com',
    :port      => '587',
    :enable_starttls_auto => true,
    :user_name => "amar@inquirly.com",
    :password  => "WVZ17wQGNB8oqasaMKOj0A",
    :authentication => 'login',
    :domain    => "inquirly.com"
  }
end
