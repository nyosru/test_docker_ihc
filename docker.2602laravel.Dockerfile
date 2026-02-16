FROM node:latest AS node
FROM php:8.2-fpm

# ================= NODE =================
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
RUN npm install -g npm@latest

# ================= ARGS =================
ARG PHPGROUP
ARG PHPUSER
ARG FOLDER

ENV PHPGROUP=${PHPGROUP}
ENV PHPUSER=${PHPUSER}
ENV FOLDER=${FOLDER}

# ================= CHROME + PANTHER =================
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    chromium \
#    chromium-driver \
#    fonts-liberation \
#    libasound2 \
#    libatk-bridge2.0-0 \
#    libatk1.0-0 \
#    libcups2 \
#    libdbus-1-3 \
#    libdrm2 \
#    libexpat1 \
#    libfontconfig1 \
#    libgbm1 \
#    libglib2.0-0 \
#    libgtk-3-0 \
#    libnspr4 \
#    libnss3 \
#    libpango-1.0-0 \
#    libcairo2 \
#    libu2f-udev \
#    libvulkan1 \
#    libx11-6 \
#    libx11-xcb1 \
#    libxcb1 \
#    libxcomposite1 \
#    libxdamage1 \
#    libxext6 \
#    libxfixes3 \
#    libxkbcommon0 \
#    libxrandr2 \
#    xdg-utils \
#    wget \
#    unzip \
#    ca-certificates \
#    git \
#    libzip-dev \
#    libxml2-dev \
#    libfreetype6-dev \
#    libjpeg62-turbo-dev \
#    libpng-dev \
#    && docker-php-ext-install pdo_mysql zip \
#    && docker-php-ext-enable zip \
#    && docker-php-ext-configure gd --with-freetype --with-jpeg \
#    && docker-php-ext-install -j$(nproc) gd \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    dbus \
    fonts-liberation \
    libnss3 \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libxshmfence1 \
    xdg-utils \
    --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

    RUN mkdir -p /run/dbus \
        && dbus-daemon --system --fork \
        && mkdir -p /tmp/chrome \
        && chmod -R 777 /tmp/chrome


    apt update && apt install -y \
        chromium \
        chromium-driver \
        dbus \
        fonts-liberation \
        libnss3 \
        libxss1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libgtk-3-0 \
        libgbm1 \
        libxshmfence1 \
        libglu1-mesa \
        xdg-utils


# ================= SYMLINKS =================
RUN ln -s /usr/bin/chromium /usr/bin/google-chrome || true
RUN ln -s /usr/bin/chromium /usr/bin/chromium-browser || true
RUN ln -s /usr/bin/chromedriver /usr/local/bin/chromedriver || true

# ================= COMPOSER =================
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ================= PERMISSIONS =================
USER root
RUN mkdir -p /var/www/.cache \
    && chmod -R 777 /var/www/.cache

RUN mkdir -p /tmp/chrome-user-data \
 && chmod -R 777 /tmp/chrome-user-data


#USER ${PHPUSER}

WORKDIR ${FOLDER}
