FROM composer:latest as composer
FROM php:8.1-fpm as base

ARG GITHUB_API_TOKEN

RUN apt-get update  && apt-get install -y \
                                   git \
                                   zip \
                                   curl \
                                   sudo \
                                   unzip \
                                   libzip-dev \
                                   libicu-dev \
                                   libbz2-dev \
                                   libpng-dev \
                                   libjpeg-dev \
                                   libmcrypt-dev \
                                   libreadline-dev \
                                   libfreetype6-dev \
                                   g++  && \
                                   rm -r /var/lib/apt/lists/*\
&& docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/laravel9

ENV PATH="$PATH:/src/vendor/bin"
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY composer.* ./
RUN composer install --no-scripts --no-autoloader --no-interaction --no-dev

FROM base as prod
RUN chgrp -R www-data storage bootstrap/cache && chmod -R ug+rwx storage bootstrap/cache \
    && composer dump-autoload --optimize

FROM base as dev
RUN composer install --no-scripts --no-autoloader --no-interaction --dev

COPY . ./
RUN chgrp -R www-data storage bootstrap/cache && chmod -R ug+rwx storage bootstrap/cache \
    && composer dump-autoload --optimize

