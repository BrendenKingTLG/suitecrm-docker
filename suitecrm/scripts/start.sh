#!/usr/bin/env bash
set -euo pipefail

cd /workspace

# Deps
[ -d vendor ] || composer install --no-interaction --no-progress
if [ -f package.json ] && [ ! -d node_modules ]; then
    rm -rf public/dist
    yarn install yarn install --frozen-lockfile
    yarn build
fi

# Fresh install if requried
if [ ! -f out/.installed.flag ]; then
  rm -f public/legacy/config.php public/legacy/config_override.php public/legacy/config_si.php
  rm -rf var/cache/* public/legacy/cache/*
  php bin/console suitecrm:app:install -n \
    -H "$(php -r '$p=parse_url(getenv("DATABASE_URL")); echo $p["host"];')" \
    -Z "$(php -r '$p=parse_url(getenv("DATABASE_URL")); echo $p["port"]??3306;')" \
    -N "$(php -r '$p=parse_url(getenv("DATABASE_URL")); echo ltrim($p["path"],"/");')" \
    -U "$(php -r '$p=parse_url(getenv("DATABASE_URL")); echo $p["user"];')" \
    -P "$(php -r '$p=parse_url(getenv("DATABASE_URL")); echo $p["pass"];')" \
    -u "${SITE_USERNAME:-admin}" \
    -p "${SITE_PASSWORD:-Admin123!}" \
    -S "${SITE_HOST:-http://localhost:8080}"
  touch out/.installed.flag
fi

# Handle Cache
php bin/console cache:clear
php bin/console cache:warmup

# Serve
exec php -S 0.0.0.0:8080 -t public
