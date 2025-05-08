#!/bin/sh
set -e

: "${ACCESS_TOKEN?}"
export enableTCP6=true
/victoria-metrics-prod -envflag.enable -storageDataPath /data/metrics &
/victoria-logs-prod -envflag.enable -storageDataPath /data/logs &
/vector.sh &

filter() { envsubst < "$1" | sponge "$1"; }
filter alertmanager.yml
alertmanager \
  --storage.path=/data/alertmanager \
  --web.external-url="${FLY_APP_NAME}.internal:9093" \
  --cluster.advertise-address="[${FLY_PRIVATE_IP}]:9094" \
  --cluster.peer="${FLY_APP_NAME}.internal:9094" &

export AWS_SDK_LOAD_CONFIG=1
export AWS_SDK_GO_LOG_LEVEL=debug
export AWS_ENABLE_SDK_LOGGING=1
export AWS_EC2_METADATA_DISABLED=true
export GF_LOG_FILTERS=plugin.athena-datasource:debug

api() { curl -sS -H "Authorization: ${ACCESS_TOKEN?}" http://_api.internal:4280/v1/$@; }
org_id=$(api "apps/$FLY_APP_NAME" | jq -r .organization.id)
export ATHENA_LOCATION=s3://fly-app-logs/query_results/org_id="$org_id"/

/run.sh
