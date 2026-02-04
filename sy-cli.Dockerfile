# Dockerfile.cli
FROM php:8.3-cli-alpine

RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

ENTRYPOINT ["symfony"]