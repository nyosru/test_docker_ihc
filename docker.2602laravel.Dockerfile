# =============================================
# Многостадийная сборка: берём Node из официального образа
# =============================================
FROM node:20 AS node

# =============================================
# Основной образ
# =============================================
FROM php:8.2-fpm

# Аргументы (передаются из docker-compose или при build)
ARG PHPGROUP=www-data
ARG PHPUSER=www-data
ARG FOLDER=/var/www/html

ENV PHPGROUP=${PHPGROUP}
ENV PHPUSER=${PHPUSER}
ENV FOLDER=${FOLDER}

# ================= Установка зависимостей и расширений =================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Для Chromium / Panther / WebDriver
    chromium \
    chromium-driver \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libxkbcommon0 \
    libgbm1 \
    libasound2 \
    libdbus-1-3 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxext6 \
    libx11-6 \
    libcairo2 \
    libpango-1.0-0 \
    libgtk-3-0 \
    fonts-liberation \
    libu2f-udev \
    xdg-utils \
    wget \
    unzip \
    ca-certificates \
    git \
    dbus \
    libzip-dev \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev

RUN apt-get update && apt-get install -y \
    docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        zip \
        gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ================= Node.js + npm (копируем из стадии node) =================
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && npm install -g npm@latest

# ================= Симлинки для совместимости с Panther =================
RUN ln -sf /usr/bin/chromium /usr/bin/google-chrome \
    && ln -sf /usr/bin/chromium /usr/bin/chromium-browser \
    && ln -sf /usr/bin/chromedriver /usr/local/bin/chromedriver

# ================= Composer =================
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ================= Подготовка директорий для Chromium / кэша =================
RUN mkdir -p /run/dbus \
    && mkdir -p /tmp/chrome-user-data \
    && mkdir -p /var/www/.cache \
    && chmod -R 777 /tmp/chrome-user-data /var/www/.cache

# ================= Рабочая директория =================
WORKDIR ${FOLDER}

# ================= Запуск dbus (нужен для Chromium в некоторых случаях) =================
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# ================= Запуск =================
CMD ["/usr/local/bin/start.sh"]