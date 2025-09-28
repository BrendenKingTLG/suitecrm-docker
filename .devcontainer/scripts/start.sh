#!/usr/bin/env bash
set -euo pipefail
cd /workspace


# PHP deps
[ -d vendor ] || composer install --no-interaction --no-progress

# Frontend deps
if [ -f package.json ] && [ ! -d node_modules ]; then
  rm -rf public/dist
  yarn install
  yarn merge-angular-json
  yarn build
fi

# resolve missing dev dep
php -r 'class_exists("Doctrine\\Bundle\\FixturesBundle\\DoctrineFixturesBundle")||exit(1);' \
  || composer require --dev doctrine/doctrine-fixtures-bundle:^3.6

if [ ! -f out/.installed.flag ] && [ ! -f public/legacy/config.php ]; then
  rm -f public/legacy/config.php public/legacy/config_override.php public/legacy/config_si.php
  rm -rf var/cache/* public/legacy/cache/*

  if [ -n "${DATABASE_URL:-}" ]; then
    read DB_HOST DB_PORT DB_NAME DB_USER DB_PASS <<< "$(php -r '$p = parse_url(getenv("DATABASE_URL") ?: ""); echo ($p["host"] ?? "") . " " . ($p["port"] ?? "3306") . " " . (isset($p["path"]) ? ltrim($p["path"], "/") : "") . " " . ($p["user"] ?? "") . " " . ($p["pass"] ?? "");')"
  fi

  DB_HOST="${DB_HOST:-${DATABASE_HOST:-localhost}}"
  DB_PORT="${DB_PORT:-${DATABASE_PORT:-3306}}"
  DB_NAME="${DB_NAME:-${DATABASE_NAME:-}}"
  DB_USER="${DB_USER:-${DATABASE_USER:-}}"
  DB_PASS="${DB_PASS:-${DATABASE_PASSWORD:-}}"

  php bin/console suitecrm:app:install -n \
    -H "${DB_HOST}" \
    -Z "${DB_PORT}" \
    -N "${DB_NAME}" \
    -U "${DB_USER}" \
    -P "${DB_PASS}" \
    -u "${SITE_USERNAME:-admin}" -p "${SITE_PASSWORD:-Admin123!}" \
    -S "${SITE_HOST:-http://localhost:8080}"
  mkdir ./out
  touch out/.installed.flag
fi

php bin/console cache:clear || true
php bin/console cache:warmup || true

exec php -S 0.0.0.0:8080 -t public
