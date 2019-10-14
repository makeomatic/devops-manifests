#!/bin/sh
set -e

ensure() {
  eval value=\$$1
  if [ -z "$value" ]; then
    echo "variable $1 shoud be set"
    exit 1
  fi
}

ensure REDIS_HOST
ensure REDIS_GROUP
ensure BACKUP_PATH

echo "Serching for a master host ..."
master=$(redis-cli -h $REDIS_HOST -p 26379 sentinel get-master-addr-by-name "$REDIS_GROUP")
masterHost=$(echo $master | cut -f1 -d " ")
redis="redis-cli -h $masterHost -p 6379"
( $redis info replication | grep -q "role:master" ) || ( echo "Not a master, exiting..."; exit 1 )

# dump data and ensire save timestamp is changed
lastsave=$($redis lastsave | sed 's/\r$//' | cut -f2 -d' ')
$redis bgsave
while true; do
  currentsave=$($redis lastsave | sed 's/\r$//' | cut -f2 -d' ')
  if [ "$currentsave" -gt "$lastsave" ]; then
    break
  fi
  echo "Waiting for background save to be finished..."
  sleep 1
done

echo "Dumping database ... "
$redis --rdb /tmp/dump.rdb
tar -czvf $BACKUP_PATH /tmp/dump.rdb

echo "Database dump created: $BACKUP_PATH"
