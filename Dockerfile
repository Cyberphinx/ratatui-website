# ---- Build Stage ----
FROM node:22-bookworm AS base
WORKDIR /app

# Install Playwright system dependencies
RUN apt-get update && apt-get install -y \
    libnss3 \
    libnspr4 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libx11-xcb1 \
    libxcursor1 \
    libgtk-3-0 \
    libpango-1.0-0 \
    libglib2.0-0 \
    libcairo2 \
    libegl1 \
    libxext6 \
    libxshmfence1 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies and Playwright
ENV HUSKY=0
RUN npm ci
RUN npx playwright install chromium

# Copy source files and build
COPY . .
RUN npm run build

# ---- Runtime Stage ----
FROM nginx:1.27-alpine AS runtime
WORKDIR /usr/share/nginx/html

# Remove default Nginx content
RUN rm -rf ./*

# Copy built static files from build stage
COPY --from=base /app/dist .

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

