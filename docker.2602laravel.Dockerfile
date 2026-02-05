FROM php:8.2-fpm

# Копируем node из образа (если нужно)
COPY --from=node:latest /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:latest /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Устанавливаем последнюю версию npm
RUN npm install -g npm@latest

ARG PHPGROUP
ARG PHPUSER
ARG FOLDER

ENV PHPGROUP=${PHPGROUP}
ENV PHPUSER=${PHPUSER}
ENV FOLDER=${FOLDER}

WORKDIR ${FOLDER}

# Установка необходимых пакетов и расширений PHP
RUN apt-get update -y \
    && apt-get install -y git libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd soap \
    && docker-php-ext-enable zip gd

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Очистка
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# ────────────────────────────────────────────────
#  SQLite: создаём файл и устанавливаем правильные права
# ────────────────────────────────────────────────

RUN mkdir -p ${FOLDER}/database \
    && touch ${FOLDER}/database/database.sqlite \
    && chown -R www-data:www-data ${FOLDER}/database \
    && chmod -R 775 ${FOLDER}/database \
    && chmod 666 ${FOLDER}/database/database.sqlite

# Права на storage и bootstrap/cache (очень важно для Laravel)
RUN chown -R www-data:www-data ${FOLDER}/storage ${FOLDER}/bootstrap/cache \
    && chmod -R 775 ${FOLDER}/storage ${FOLDER}/bootstrap/cache

USER www-data