FROM php:8.1-fpm

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    git curl zip unzip ca-certificates gnupg \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev \
    libldap2-dev libsasl2-dev \
    libicu-dev \
    default-mysql-client; \
  rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN set -eux; \
  docker-php-ext-configure gd --with-freetype --with-jpeg; \
  docker-php-ext-install -j"$(nproc)" \
    pdo_mysql mysqli mbstring exif pcntl bcmath gd zip ldap intl opcache

# Dev PHP ini
RUN printf "memory_limit=1G\npost_max_size=8M\nupload_max_filesize=8M\n" \
  > /usr/local/etc/php/conf.d/zz-app.ini

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node 18 + Yarn (global CLI optional)
RUN set -eux; \
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash -; \
  apt-get update; apt-get install -y --no-install-recommends nodejs; \
  rm -rf /var/lib/apt/lists/*; \
  npm i -g yarn

WORKDIR /workspace
