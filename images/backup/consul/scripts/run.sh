#!/bin/sh
set -e

ensure() {
  eval value=\$$1
  if [ -z "$value" ]; then
    echo "variable $1 shoud be set"
    exit 1
  fi
}

ensure CONSUL_HOST
ensure BACKUP_PATH

echo "Dumping kv from $CONSUL_HOST ..."
consul kv export -http-addr=$CONSUL_HOST:8500 > /tmp/consul.json
ls /tmp
tar -czvf $BACKUP_PATH /tmp/consul.json

echo "Dump created: $BACKUP_PATH"
