# Puma configuration for Rails + Vite production

# Workers and threads
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Port from Railway
port ENV.fetch("PORT", 3000)

# Environment
environment ENV.fetch("RAILS_ENV", "development")

# Worker count (0 for single process)
workers ENV.fetch("WEB_CONCURRENCY", 0)

# Preload for workers (if > 0)
if ENV.fetch("WEB_CONCURRENCY", 0).to_i > 0
  preload_app!
end

# Quiet output
quiet

# Allow puma to be restarted by `bin/rails restart`
plugin :tmp_restart
