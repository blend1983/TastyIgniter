#!/bin/sh

echo "Starting TastyIgniter..."

if [ -n "$PORT" ]; then
  export SERVER_NAME=":${PORT}"
fi

echo "Ensuring storage symlink..."
php /app/artisan storage:link 2>&1 || echo "storage:link failed or skipped (this is OK)"

echo "Running Laravel migrations..."
php /app/artisan migrate --force 2>&1 || echo "Migrations failed or skipped (this is OK)"

echo "Starting FrankenPHP..."
exec frankenphp run --config /etc/caddy/Caddyfile
