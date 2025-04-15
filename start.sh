#!/bin/sh
set -e

: "${ACCESS_TOKEN?}"
export enableTCP6=true
/victoria-metrics-prod -envflag.enable -storageDataPath /data/metrics &
/victoria-logs-prod -envflag.enable -storageDataPath /data/logs &
/vector.sh &

/run.sh
