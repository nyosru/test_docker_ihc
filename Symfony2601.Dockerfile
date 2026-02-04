FROM php:8.3-fpm-alpine

ENV FOLDER=${FOLDER}

RUN apk add --no-cache \
    git \
    unzip \
    bash \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Symfony CLI
# RUN curl -sS https://get.symfony.com/cli/installer | bash && \
#    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR ${FOLDER}

# Копируем composer файлы и устанавливаем зависимости
#COPY composer.json composer.lock ./
#RUN composer install --no-dev --no-scripts --no-autoloader
#
#COPY . .
#RUN composer dump-autoload --optimize

# Права (для dev)
#RUN chown -R www-data:www-data ${FOLDER}

CMD ["php-fpm"]