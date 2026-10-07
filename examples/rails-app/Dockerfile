FROM ruby:3.4-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs npm libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the production Gemfile and its lockfile, and install exactly the
# locked versions (BUNDLE_FROZEN fails the build if they don't match)
COPY Gemfile.production ./Gemfile
COPY Gemfile.production.lock ./Gemfile.lock
ENV BUNDLE_WITHOUT="development:test" \
    BUNDLE_FROZEN=true
RUN bundle install

# Copy application files
COPY config.ru ./
COPY config/ ./config/
COPY app/controllers/ ./app/controllers/
COPY app/views/ ./app/views/
COPY bin/ ./bin/

# Pre-built assets (RAILS_ENV=production bin/vite build) and their manifest,
# resolved by vite_javascript_tag
COPY public/vite/ ./public/vite/

# Create necessary directories
RUN mkdir -p tmp/pids log

# Environment
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV SECRET_KEY_BASE=dummy_secret_for_demo_only_do_not_use_in_real_production

# Expose port
EXPOSE 3000

# Start Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
