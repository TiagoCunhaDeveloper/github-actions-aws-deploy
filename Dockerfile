# syntax=docker/dockerfile:1

# ---- Stage 1: build ----
FROM node:20-alpine AS builder
WORKDIR /app

# Install deps first to leverage Docker layer caching.
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Drop dev dependencies so they don't leak into the runtime image.
RUN npm prune --omit=dev

# ---- Stage 2: runtime ----
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Run as the unprivileged user that the node image already ships with.
USER node

COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/dist ./dist
COPY --chown=node:node --from=builder /app/package.json ./package.json

EXPOSE 3000

# Container-level healthcheck (useful for `docker run`; ECS uses its own check too).
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://localhost:'+(process.env.PORT||3000)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "dist/main.js"]
