#!/bin/sh
export enableTCP6=true
/victoria-metrics-prod -envflag.enable -storageDataPath /data/metrics &
/victoria-logs-prod -envflag.enable -storageDataPath /data/logs &
/vector.sh &

GF_PATHS_DATA=/data/grafana /run.sh
