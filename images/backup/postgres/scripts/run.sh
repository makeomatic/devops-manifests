#!/bin/sh
set -e

ensure() {
  eval value=\$$1
  if [ -z "$value" ]; then
    echo "variable $1 shoud be set"
    exit 1
  fi
}

ensure PG_HOST
ensure PG_USER
ensure PG_PASSWORD
ensure PG_DATABASE
ensure BACKUP_PATH

echo "Dumping $PG_DATABASE ..."
PGPASSWORD="$PG_PASSWORD" pg_dump  --file=/tmp/dump --format=directory --host=$PG_HOST --user=$PG_USER $PG_DATABASE
tar -czvf "$BACKUP_PATH" /tmp/dump/

echo "Database dump created: $BACKUP_PATH"
