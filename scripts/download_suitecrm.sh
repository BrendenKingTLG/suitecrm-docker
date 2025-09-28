#!/usr/bin/env bash
set -euo pipefail

mkdir -p ./suitecrm

curl -L \
  -o suitecrm/SuiteCRM-8.9.0-dev.zip \
  https://github.com/SuiteCRM/SuiteCRM-Core/releases/download/v8.9.0/SuiteCRM-8.9.0-dev.zip

unzip -q suitecrm/SuiteCRM-8.9.0-dev.zip -d suitecrm

rm suitecrm/SuiteCRM-8.9.0-dev.zip
