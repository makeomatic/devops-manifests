#!/usr/bin/env bash
set -e

basedir=$(dirname "$0")
project="$1"
environment="$2"

if [ -z "$project" ] || [ -z "$environment" ]; then
  echo "Usage: ./script.sh {project} {environment}"
  exit 1
fi

tmp_dir=$(mktemp -d -t prom)
jsonnet manifests/prometheus.jsonnet > "$tmp_dir"/manifests.json

node "$basedir"/parse-alertmanager.js "$tmp_dir"/manifests.json group=absence-test environment="$environment" component=monitoring severity=none project="$project" > "$tmp_dir"/absence.json

kubectl apply -f "$tmp_dir"/manifests.json
kubectl apply -f "$tmp_dir"/absence.json
rm -R "$tmp_dir"
