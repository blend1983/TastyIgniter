#!/bin/sh

echo "Starting TastyIgniter..."
echo "Running Laravel migrations..."
php /app/artisan migrate --force 2>&1 || echo "Migrations failed or skipped (this is OK)"

echo "Starting FrankenPHP..."
exec frankenphp run --config /etc/caddy/Caddyfile
