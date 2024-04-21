# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  Dotenv.load(*%w[.env.local .env].select do |file|
    File.exist?(file)
  end)

  # Enable web console for all IP addresses (see https://stackoverflow.com/a/71292229)
  # To enable all IP v6 addresses, use '::/0'
  config.web_console.permissions = '0.0.0.0/0'

  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports. See https://guides.rubyonrails.org/configuring.html#config-consider-all-requests-local
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  config.rails_semantic_logger.started    = true
  config.rails_semantic_logger.processing = true
  config.rails_semantic_logger.rendered   = true
  config.semantic_logger.backtrace_level = :info
  config.log_level = :debug

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_deliveries = AppUtils.letter_opener_enabled?
  config.action_mailer.delivery_method =
    if AppUtils.send_emails?
      :smtp
    else
      :letter_opener
    end
  # Configure the mailer to use the SMTP server
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_SERVER', Rails.application.credentials.brevo.smtp_server),
    port: ENV.fetch('SMTP_PORT', Rails.application.credentials.brevo.smtp_port),
    user_name: ENV.fetch('SMTP_USERNAME', Rails.application.credentials.brevo.smtp_user),
    password: ENV.fetch('SMTP_PASSWORD', Rails.application.credentials.brevo.smtp_password),
    enable_starttls_auto: true
  }

  config.after_initialize do
    # Configure logging for the app's mail service. ActionMailer config docs: https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration
    config.action_mailer.logger = Rails.logger
  end

  config.action_mailer.default_url_options = { host: 'localhost', port: ENV.fetch('PORT') }

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.assets.digest = false

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
end
