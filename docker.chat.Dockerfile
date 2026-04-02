# Лёгкий CLI-образ, без fpm (нам не нужен PHP-FPM)
FROM php:8.2-cli

# Переключимся на root, чтобы ставить пакеты
USER root

# Обновляем пакеты и ставим зависимости для composer-пакетов
RUN apt-get update -y \
    && apt-get install -y git unzip libzip-dev libxml2-dev \
    && docker-php-ext-install zip \
    && docker-php-ext-enable zip

# Ставим composer из timeweb-образа, как у тебя
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Дальше уже твой код
WORKDIR /home/chat-service

# Кладём composer.json/lock и код
#COPY . /home/chat-service

# Устанавливаем зависимости
RUN composer install --no-dev --optimize-autoloader

# Можно оставить CMD, если хочешь, чтобы контейнер сразу запускал что-то
# например, просто "ничего не делать" и мы будем использовать docker exec
# CMD ["php", "-v"]