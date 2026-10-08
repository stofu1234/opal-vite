# Build stage: compilers are only needed to build native gems
FROM ruby:3.4-slim AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the production Gemfile and its lockfile, and install exactly the
# locked versions (BUNDLE_FROZEN fails the build if they don't match)
COPY Gemfile.production ./Gemfile
COPY Gemfile.production.lock ./Gemfile.lock
ENV BUNDLE_FROZEN=true
RUN bundle install && \
    rm -rf /usr/local/bundle/cache

# Runtime stage: no compilers and no Node (the assets are pre-built)
FROM ruby:3.4-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libyaml-0-2 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --uid 1000 rails

WORKDIR /app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app/Gemfile /app/Gemfile.lock ./

# Copy application files
COPY config.ru ./
COPY config/ ./config/
COPY app/controllers/ ./app/controllers/
COPY app/views/ ./app/views/
COPY bin/ ./bin/

# Pre-built assets (RAILS_ENV=production bin/vite build) and their manifest,
# resolved by vite_javascript_tag
COPY public/vite/ ./public/vite/

# Rails writes to tmp/ and log/; everything else stays root-owned
RUN mkdir -p tmp/pids log && chown -R rails:rails tmp log

# Environment. Set SECRET_KEY_BASE in the platform's variables if the app ever
# uses sessions or cookies; this demo does not (see config/environments/production.rb).
ENV BUNDLE_FROZEN=true \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

USER rails

# Expose port
EXPOSE 3000

# Start Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
