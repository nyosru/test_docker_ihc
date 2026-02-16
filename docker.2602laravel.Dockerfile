FROM php:8.2-fpm

# Аргументы
ARG PHPGROUP=www-data
ARG PHPUSER=www-data
ARG FOLDER=/var/www/html

ENV PHPGROUP=${PHPGROUP}
ENV PHPUSER=${PHPUSER}
ENV FOLDER=${FOLDER}

# Установка всех зависимостей одним слоем
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium chromium-driver \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libxkbcommon0 libgbm1 libasound2 \
    libdbus-1-3 libdrm2 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libxext6 libx11-6 libcairo2 libpango-1.0-0 libgtk-3-0 \
    fonts-liberation libu2f-udev xdg-utils libxshmfence1 \
    libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    git wget unzip ca-certificates dbus \
    && \
    docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql zip gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Симлинки для Panther (Panther ищет google-chrome и chromedriver)
RUN ln -sf /usr/bin/chromium /usr/bin/google-chrome \
    && ln -sf /usr/bin/chromium /usr/bin/chromium-browser \
    && ln -sf /usr/bin/chromedriver /usr/local/bin/chromedriver

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Директории для Chromium (обязательно с правами 777)
RUN mkdir -p /run/dbus /tmp/chrome-user-data /var/www/.cache \
    && chmod -R 777 /tmp/chrome-user-data /var/www/.cache

# Запуск dbus + php-fpm
COPY <<EOF /usr/local/bin/start.sh
#!/bin/bash
dbus-daemon --system --fork || echo "dbus failed"
exec php-fpm
EOF

RUN chmod +x /usr/local/bin/start.sh

WORKDIR ${FOLDER}

CMD ["/usr/local/bin/start.sh"]