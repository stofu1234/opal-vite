require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"],
  # config/master.key, or an environment key such as config/credentials/production.key.
  # This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # Railway terminates TLS at its proxy and forwards X-Forwarded-Proto, which
  # Rails trusts. The health check (/up) comes in over plain http, so it is
  # excluded from the redirect.
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Per-boot fallback so the app still starts when SECRET_KEY_BASE is not set.
  # This demo has no sessions, cookies or credentials, so nothing depends on it.
  # An app that does must set SECRET_KEY_BASE (e.g. `bin/rails secret`).
  config.secret_key_base = ENV["SECRET_KEY_BASE"].presence || SecureRandom.hex(64)

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Info include generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # ActiveRecord is not used in this demo app

  # Only answer for the Railway domains. Railway sets RAILWAY_PUBLIC_DOMAIN;
  # add other domains (comma separated) with APP_HOSTS. /up (the health check,
  # sent with Host: healthcheck.railway.app) is excluded by default.
  config.hosts << ".up.railway.app"
  config.hosts << ENV["RAILWAY_PUBLIC_DOMAIN"] if ENV["RAILWAY_PUBLIC_DOMAIN"].present?
  ENV.fetch("APP_HOSTS", "").split(",").map(&:strip).reject(&:empty?).each { |host| config.hosts << host }
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Content Security Policy. The page loads only same-origin Vite output (an ES
  # module; the Opal runtime does not call eval at load time) and has one inline
  # <style>, allowed by a per-request nonce.
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src  :self
    policy.style_src   :self
    policy.img_src     :self, :data
    policy.font_src    :self, :data
    policy.connect_src :self
    policy.object_src  :none
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
  end
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[style-src]

  # Enable static file serving for Railway (no nginx/apache in front)
  config.public_file_server.enabled = true
end
