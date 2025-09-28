FROM php:8.1-fpm

# OS + PHP deps
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    git curl zip unzip ca-certificates gnupg \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev \
    libldap2-dev libsasl2-dev libicu-dev \
    default-mysql-client; \
  rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN set -eux; \
  docker-php-ext-configure gd --with-freetype --with-jpeg; \
  docker-php-ext-install -j"$(nproc)" pdo_mysql mysqli mbstring exif pcntl bcmath gd zip ldap intl opcache

# PHP ini
RUN printf "memory_limit=1G\npost_max_size=8M\nupload_max_filesize=8M\n" > /usr/local/etc/php/conf.d/zz-app.ini

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node + Yarn
RUN set -eux; \
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash -; \
  apt-get update; apt-get install -y --no-install-recommends nodejs; \
  rm -rf /var/lib/apt/lists/*; \
  npm i -g yarn \
  corepack enable \
  && COREPACK_ENABLE_DOWNLOADS=1 corepack prepare yarn@4.9.4 --activate
  
WORKDIR /workspace

# App code (adjust source paths as needed)
# COPY SuiteCRM-8.9.0-dev/ /workspace/
# COPY scripts/ /workspace/scripts/

# # Writable dirs for runtime
# RUN set -eux; \
#   install -d -o www-data -g www-data -m 775 \
#     /workspace/var \
#     /workspace/public/dist \
#     /workspace/public/legacy/cache \
#     /workspace/public/legacy/upload; \
#   # make console and scripts executable
#   chmod +x /workspace/bin/console || true; \
#   find /workspace/scripts -type f -name "*.sh" -exec chmod +x {} \; || true

# Give www-data a real, writable HOME for VS Code server, Composer, Yarn caches
# give www-data a real home
# ENV HOME=/home/www-data
# ENV COMPOSER_HOME=/home/www-data/.composer
# ENV PATH="/workspace/vendor/bin:${PATH}"
# ENV XDG_CACHE_HOME=/home/www-data/.cache
