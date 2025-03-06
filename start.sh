#!/bin/sh
# Use TLS gossip traffic config with self-signed cert, since default TCP+UDP config
# doesn't work on Fly.io (Memberlist binds both TCP+UDP listeners to the same address)
# https://prometheus.io/docs/alerting/latest/https/#gossip-traffic
apk add openssl
openssl req -x509 -newkey rsa:2048 -keyout ha_key.pem -out ha_cert.pem -days 365 -nodes -batch
cat <<YAML > /ha_tls.yml
tls_server_config: {cert_file: /ha_cert.pem, key_file: /ha_key.pem}
tls_client_config: {insecure_skip_verify: true}
YAML

/victoria-metrics-prod -envflag.enable -storageDataPath /data/metrics &
/victoria-logs-prod -envflag.enable -storageDataPath /data/logs &
vector &
/run.sh
