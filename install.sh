#!/bin/bash

cd /var/www || exit

# TEMPLATE
echo 'Install TEMPLATE'

if [[ ! -d "/var/www/TEMPLATE/.git" ]]; then
  mkdir -p "/var/www/TEMPLATE"
  # default is master, but we want develop to work
  git -C /var/www/TEMPLATE clone --branch develop YOUR_GIT_URL .
else
  git -C /var/www/TEMPLATE pull
fi

composer install -d /var/www/TEMPLATE --no-interaction

chmod -R 0777 "/var/www/TEMPLATE/var/cache"
chmod -R 0777 "/var/www/TEMPLATE/var/logs"

if [[ -f "/var/www/TEMPLATE/yarn.lock" ]]; then
  yarn --cwd "/var/www/TEMPLATE" install
  yarn --cwd "/var/www/TEMPLATE" encore prod
fi
