#!/bin/bash

# Запускаем системный dbus-daemon в фоне (fork)
# Это критично для headless Chromium в некоторых случаях
dbus-daemon --system --fork

# Запускаем основной процесс контейнера — php-fpm
# exec нужен, чтобы php-fpm стал PID 1 и получал сигналы (SIGTERM и т.д.)
exec php-fpm