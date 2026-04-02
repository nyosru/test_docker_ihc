FROM php:8.1-fpm

ARG PHPGROUP=www-data
ARG PHPUSER=www-data
ARG FOLDER=/var/www/html

ENV PHPGROUP=${PHPGROUP}
ENV PHPUSER=${PHPUSER}
ENV FOLDER=${FOLDER}

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    mbstring \
    gd \
    xml \
    opcache \
    zip

RUN pecl install xdebug redis \
    && docker-php-ext-enable xdebug redis

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN mkdir -p /home/2603bitrix_test/session_tmp \
    && chown -R www-data:www-data /home/2603bitrix_test/session_tmp \
    && chmod -R 777 /home/2603bitrix_test/session_tmp

WORKDIR ${FOLDER}