# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Mailer configuration
config.action_mailer.smtp_settings = {
  :address => 'localhost',
  :domain => 'gomoshi.com'
}

config.action_mailer.default_url_options = {
  :host => 'my.teleweave.com'
}
config.action_mailer.delivery_method = :sendmail
config.action_mailer.delivery_method = :smtp
config.action_mailer.raise_delivery_errors = true

# Setup cookies to work with base domain
config.action_controller.session[:domain] = ".teleweave.com"
