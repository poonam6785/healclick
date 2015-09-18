::SENDING_EMAILS = true

Healclick::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  Rails.application.routes.default_url_options[:host] = 'ec2-54-68-4-94.us-west-2.compute.amazonaws.com'

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  ELASTICACHE_ENDPOINT = YAML.load_file("#{Rails.root}/config/elasticache.yml")[Rails.env]
  if ELASTICACHE_ENDPOINT
    elasticache = Dalli::ElastiCache.new(ELASTICACHE_ENDPOINT)
    config.cache_store = :dalli_store, elasticache.servers, {:expires_in => 1.day, :compress => true}
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.log_level = :error

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  config.action_mailer.delivery_method = :smtp

  config.serve_static_assets = false
  config.assets.js_compressor = :uglifier
  config.assets.compile = true
  config.assets.digest = true
  config.assets.version = '1.0'
  
  config.assets.precompile += %w( head_application.js )

  config.action_controller.asset_host = "http://ec2-54-68-4-94.us-west-2.compute.amazonaws.com/"
  config.action_mailer.asset_host = "http://s3.amazonaws.com/healclick-staging"

  config.assets.prefix = "/assets"

  config.action_mailer.smtp_settings = {
    :address              => "email-smtp.us-east-1.amazonaws.com",
    :port                 => 587,
    :domain               => 'healclick.com',
    :user_name            => 'AKIAJLFYGOLZP5I62A7Q',
    :password             => 'AhMdTcqW52Azgy7ZOePwSttntZLmWwoF2VFySnLGzC5k',
    :authentication       => 'plain',
    :enable_starttls_auto => true 
  }

  config.middleware.use 'Rack::Maintenance',
    :file => Rails.root.join('public', 'maintenance.html')

end