# ViteRails configuration
if defined?(ViteRuby)
  ViteRuby.configure do |config|
    # Vite dev server host
    config.host = 'localhost'

    # Vite dev server port
    config.port = 5173

    # Auto-build in production
    config.auto_build = true
  end
end
