Rails.application.configure do

  # config.relative_url_root = "/panorama"
  # Settings specified here will take precedence over those in config/application.rb.

  # Configure Bullet gem
  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.alert = true
  #   Bullet.bullet_logger = true
  #   Bullet.console = true
  # end

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  # config.cache_store = :memory_store, { size: 1024.megabytes }
  config.cache_store = :dalli_store

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Set logger level
  # config.log_level = :info

  # Set logger max size to 50MB in development mode
  config.logger = ActiveSupport::Logger.new(config.paths['log'].first, 1, 50 * 1024 * 1024)

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false

  config.assets.js_compressor = :uglifier

  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # config.assets.debug = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

end
