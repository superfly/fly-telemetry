#!/bin/sh
set -e
# Add Vector-sink configs for all peer machines in the app.
api() { curl -sS -H "Authorization: ${ACCESS_TOKEN?}" http://_api.internal:4280/v1/$1; }
dir=/etc/vector/sinks; mkdir -p $dir
for peer in $(api "apps/$FLY_APP_NAME/machines" | jq -r .[].id | grep -v "$FLY_MACHINE_ID"); do
  cat <<YAML > "$dir/$peer.yaml"
type: vector
inputs: ['logs', '*-metrics']
healthcheck: {enabled: false}
compression: true
address: "$peer.vm.$FLY_APP_NAME.internal:6000"
buffer: {type: disk, max_size: ${DISK_BUFFER:-268435488}, when_full: drop_newest}
YAML
  done
export VECTOR_WATCH_CONFIG=true
export VECTOR_CONFIG_DIR=/etc/vector
exec vector
