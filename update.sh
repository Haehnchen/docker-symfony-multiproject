#!/bin/bash

# All project inside "/var/*"
#declare -a projects=("TEMPLATE" "TEMPLATE2")
declare -a projects=("TEMPLATE")

# Read the array values with space
for project in "${projects[@]}"; do
  if [[ ! -d "/var/www/$project" ]]; then
    echo "Skipping $project"
  else
    echo "Update $project"
    git -C "/var/www/$project" checkout develop

    if [[ -f "/var/www/$project/composer.lock" ]]; then
      composer install -v -d "/var/www/$project" --no-interaction
    fi

    if [[ -d "/var/www/$project/var/cache" ]]; then
      chmod -R 0777 "/var/www/$project/var/cache"
    fi

    if [[ -d "/var/www/$project/var/logs" ]]; then
      chmod -R 0777 "/var/www/$project/var/logs"
    fi
  fi

  if [[ -f "/var/www/$project/gulpfile.js" ]]; then
    gulp --cwd "/var/www/$project" build
  fi

  if [[ -f "/var/www/$project/yarn.lock" ]]; then
    yarn --cwd "/var/www/$project" install
    yarn --cwd "/var/www/$project" encore prod
  fi
done
