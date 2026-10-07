# Build stage: compiling the Opal code needs Ruby (opal-vite gem) and Node (Vite).
FROM node:22-slim AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends ruby-full build-essential && \
    rm -rf /var/lib/apt/lists/*

# No Gemfile in the image (its opal-vite is a path gem outside this directory),
# so vite-plugin-opal uses these globally installed gems.
RUN gem install --no-document opal -v '~> 1.8' && \
    gem install --no-document opal-vite -v '~> 0.3'

WORKDIR /app
COPY package.json ./
RUN npm install

COPY . .
RUN npm run build

# Runtime stage: serves dist/ and the WebSocket server, no Ruby needed.
FROM node:22-slim

WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

COPY --from=build /app/dist ./dist
COPY production-server.mjs ./

EXPOSE 3017

CMD ["node", "production-server.mjs"]
