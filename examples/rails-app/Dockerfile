FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs npm libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy production Gemfile
COPY Gemfile.production ./Gemfile
RUN bundle install --without development test

# Copy application files
COPY config.ru ./
COPY config/ ./config/
COPY app/controllers/ ./app/controllers/
COPY app/views/ ./app/views/
COPY bin/ ./bin/

# Copy pre-built assets to public directory for Rails static serving
COPY dist/assets/ ./public/assets/

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
