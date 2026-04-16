#!/bin/sh
set -e

echo "Running Laravel migrations..."
php /app/artisan migrate --force

echo "Starting FrankenPHP..."
exec frankenphp run --config /etc/caddy/Caddyfile
