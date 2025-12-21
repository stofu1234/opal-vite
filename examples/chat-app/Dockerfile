FROM node:22-slim

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy pre-built dist folder and production server
COPY dist/ ./dist/
COPY production-server.mjs ./

# Expose port (Railway sets PORT env var)
EXPOSE 3006

# Start production server
CMD ["node", "production-server.mjs"]
