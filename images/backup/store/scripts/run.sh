#!/bin/sh
set -e

ensure() {
  eval value=\$$1
  if [ -z "$value" ]; then
    echo "variable $1 shoud be set"
    exit 1
  fi
}

ensure CLOUDSDK_API_KEY
ensure BACKUP_PATH
ensure BUCKET_PATH
ensure BUCKET_NAME

echo "Setting up kubernetes access ..."
echo "$CLOUDSDK_API_KEY" | base64 -d > ./gcloud-api-key.json
gcloud auth activate-service-account --key-file gcloud-api-key.json

filename=$(basename $BACKUP_PATH)
bucket="gs://$BUCKET_NAME/$BUCKET_PATH/$(date +"%d")-$filename"

echo "Copying $BACKUP_PATH to $bucket ..."
gsutil cp $BACKUP_PATH $bucket 2>&1
echo "Backup is finished"
