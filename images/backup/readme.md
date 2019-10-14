# Backup images
Set of docker images to create backups in cloud-native environment.

## Build

### store
Store backup data to google bucket
```
skaffold build -p store
```
Required envs: CLOUDSDK_API_KEY, BACKUP_PATH, BUCKET_PATH, BUCKET_NAME

### consul
Backup consul key/value data
```
skaffold build -p consul
```
Required envs: CONSUL_HOST, BACKUP_PATH


### postgres
Dump postgresql database
```
skaffold build -p postgres
```
Required envs: PG_HOST, PG_USER, PG_PASSWORD, PG_DATABASE, BACKUP_PATH

### redis
Dump redis sentinel cluster data
```
skaffold build -p redis
```
Required envs: REDIS_HOST, REDIS_GROUP, BACKUP_PATH

### rethinkdb
Dump rethinkdb database
```
skaffold build -p rethinkdb
```
Required envs: RETHINKDB_HOST, RETHINKDB_DB, RETHINKDB_PASSWORD, BACKUP_PATH

Backup example:
```
docker run \
  -v /tmp/dump:/dump \
	-e RETHINKDB_HOST=rethinkdb-rethinkdb-proxy.default.svc.cluster.local \
	-e RETHINKDB_DB=tinode \
	-e RETHINKDB_PASSWORD="***" \
	-e BACKUP_PATH=/backup.tar.gz \
	makeomatic/cloud-backup:rethinkdb
```

Restore example:
```
docker run \
    -it \
	-v /tmp/dump:/dump \
	-e RETHINKDB_HOST=rethinkdb-rethinkdb-proxy.default.svc.cluster.local \
	-e RETHINKDB_DB=tinode \
	-e RETHINKDB_PASSWORD="***" \
	-e BACKUP_PATH=/dump/backup.tar.gz \
	makeomatic/cloud-backup:rethinkdb sh

echo "$RETHINKDB_PASSWORD" > ./password
rethinkdb-restore /dump/tinode_12-database.tar -c $RETHINKDB_HOST --password-file ./password --force -i tinode
```

## Kubernetes cronjob example
Following job dumps redis data on daily basis and stores its to google bucket.
