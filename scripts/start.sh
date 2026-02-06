#!/bin/sh
set -x

scripts/replace-placeholder.sh "$BUILT_NEXT_PUBLIC_WEBAPP_URL" "$NEXT_PUBLIC_WEBAPP_URL"

# Fix 1: Use proper host:port and add a timeout/retry
# Railway Postgres default port is 5432
echo "Waiting for database..."
timeout=60
while ! nc -z ${DATABASE_HOST} 5432 2>/dev/null; do
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "Timed out waiting for database"
    exit 1
  fi
  sleep 1
done
echo "Database is up"

npx prisma migrate deploy --schema /calcom/packages/prisma/schema.prisma
npx ts-node --transpile-only /calcom/scripts/seed-app-store.ts
yarn start
