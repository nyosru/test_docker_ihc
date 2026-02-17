FROM node:20-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libnss3 \
    libxss1 \
    libasound2 \
    libgbm1 \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV CHROME_PATH=/usr/bin/chromium

COPY package.json ./
RUN npm install

COPY server.js ./

EXPOSE 3000

CMD ["node", "server.js"]
