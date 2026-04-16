#!/bin/sh
set -e

echo "Starting FrankenPHP..."
exec frankenphp run --config /etc/caddy/Caddyfile
