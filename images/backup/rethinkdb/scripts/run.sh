#!/bin/sh
set -e

ensure() {
  eval value=\$$1
  if [ -z "$value" ]; then
    echo "variable $1 shoud be set"
    exit 1
  fi
}

ensure RETHINKDB_HOST
ensure RETHINKDB_DB
ensure RETHINKDB_PASSWORD
ensure BACKUP_PATH

echo "$RETHINKDB_PASSWORD" > ./password

echo "Backing up ${RETHINKDB_HOST}:${RETHINKDB_DB} to ${BACKUP_PATH} ..."
rethinkdb-dump -c $RETHINKDB_HOST:28015 --overwrite-file -f $BACKUP_PATH -e $RETHINKDB_DB --password-file ./password
