#!/bin/sh
# Add Vector-sink configs for all peer machines in the app.
api=http://_api.internal:4280/v1/apps/$FLY_APP_NAME/machines
config=/etc/vector/vector_peers.yaml
disk_buffer=${DISK_BUFFER:-268435488}
echo "sinks:" >> "$config"
for peer in $(curl -sS "$api" -H "Authorization: ${ACCESS_TOKEN?}" | jq -r .[].id | grep -v "$FLY_MACHINE_ID"); do
  cat <<YAML >> "$config"
  vector_metrics_$peer:
    type: vector
    inputs: [metrics]
    healthcheck: {enabled: false}
    compression: true
    address: "$peer.vm.$FLY_APP_NAME.internal:6000"
    buffer: {type: disk, max_size: $disk_buffer, when_full: drop_newest}
    batch: {aggregate: false}
  vector_logs_$peer:
    type: vector
    inputs: [logs]
    healthcheck: {enabled: false}
    compression: true
    address: "$peer.vm.$FLY_APP_NAME.internal:6001"
    buffer: {type: disk, max_size: $disk_buffer, when_full: drop_newest}
YAML
  done
exec vector
