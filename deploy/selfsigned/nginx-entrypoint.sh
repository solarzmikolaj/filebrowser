#!/bin/sh

set -eu

while [ ! -f /etc/nginx/tls/tls.crt ] || [ ! -f /etc/nginx/tls/tls.key ]; do
  echo "Waiting for TLS certificate..."
  sleep 1
done

exec nginx -g "daemon off;"
