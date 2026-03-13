# Dockerfile (tested pattern for headless Chromium + Node 18)
FROM node:18-bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system deps and chromium
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    dirmngr \
    build-essential \
    python3 \
    xz-utils \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    libxss1 \
    libgbm1 \
    wget \
    git \
    chromium \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Hugging Face Spaces require a non-root user with UID 1000
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Create and use app dir
WORKDIR $HOME/app

# Copy package files first for caching, ensuring 'user' owns them
COPY --chown=user:user package*.json ./

# Install node deps
RUN npm ci --production || npm install --production

# Copy app sources, ensuring 'user' owns them
COPY --chown=user:user . .

# Expose port required by Hugging Face
EXPOSE 7860

# Default env vars (override in HF if needed)
ENV PORT=7860
ENV CHROMIUM_PATH=/usr/bin/chromium
ENV DUMP_IO=false

CMD ["node", "server.js"]
