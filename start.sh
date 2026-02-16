#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SERVICE_PATH="/home/2602test_laravel"

echo -e "${GREEN}🚀 Начинаем развертывание 2602test_laravel${NC}"

# Переходим в директорию сервиса
cd $SERVICE_PATH || {
    echo -e "${RED}❌ Ошибка: Директория $SERVICE_PATH не найдена${NC}"
    exit 1
}

# Создаем необходимые директории
echo -e "${YELLOW}📁 Создаем директории...${NC}"
mkdir -p storage/logs/chromedriver
mkdir -p storage/app/chrome-data
mkdir -p storage/framework/{sessions,views,cache}
mkdir -p bootstrap/cache

# Устанавливаем права
echo -e "${YELLOW}🔧 Устанавливаем права доступа...${NC}"
chmod -R 775 storage
chmod -R 775 bootstrap/cache
chmod -R 777 storage/logs/chromedriver
chmod -R 777 storage/app/chrome-data

# Проверяем .env файл
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 Создаем .env файл...${NC}"
    cp .env.example .env 2>/dev/null || {
        echo -e "${RED}❌ .env.example не найден. Создайте .env вручную${NC}"
        exit 1
    }
    echo -e "${YELLOW}⚠️  Отредактируйте .env файл и запустите скрипт снова${NC}"
    exit 0
fi

# Собираем образ
echo -e "${YELLOW}🏗️  Сборка Docker образа...${NC}"
docker-compose build --no-cache

# Останавливаем старые контейнеры
echo -e "${YELLOW}🛑 Останавливаем старые контейнеры...${NC}"
docker-compose down

# Запускаем новые контейнеры
echo -e "${YELLOW}▶️  Запускаем контейнеры...${NC}"
docker-compose up -d

# Ждем запуска
echo -e "${YELLOW}⏳ Ожидаем запуска контейнеров...${NC}"
sleep 10

# Проверяем статус
if [ "$(docker inspect -f '{{.State.Running}}' 2602test_laravel 2>/dev/null)" = "true" ]; then
    echo -e "${GREEN}✅ Контейнер 2602test_laravel успешно запущен${NC}"
else
    echo -e "${RED}❌ Ошибка запуска контейнера${NC}"
    docker logs 2602test_laravel
    exit 1
fi

# Тестируем Chrome
echo -e "${YELLOW}🧪 Тестируем Chrome...${NC}"
docker exec 2602test_laravel test-chrome.sh

# Устанавливаем зависимости Laravel
echo -e "${YELLOW}📦 Устанавливаем зависимости Composer...${NC}"
docker exec -w /var/www/html 2602test_laravel composer install --no-dev --optimize-autoloader

# Генерируем ключ
echo -e "${YELLOW}🔑 Генерируем ключ приложения...${NC}"
docker exec -w /var/www/html 2602test_laravel php artisan key:generate --force

# Кэшируем конфигурацию
echo -e "${YELLOW}⚙️  Кэшируем конфигурацию...${NC}"
docker exec -w /var/www/html 2602test_laravel php artisan config:cache
docker exec -w /var/www/html 2602test_laravel php artisan route:cache
docker exec -w /var/www/html 2602test_laravel php artisan view:cache

# Проверяем логи ChromeDriver
echo -e "${YELLOW}📋 Логи ChromeDriver:${NC}"
docker exec 2602test_laravel tail -n 20 /var/log/chromedriver/chromedriver.log 2>/dev/null || echo "Лог-файл пока пуст"

echo -e "${GREEN}✅ Развертывание завершено!${NC}"
echo -e "${GREEN}📊 Контейнеры:${NC}"
docker-compose ps