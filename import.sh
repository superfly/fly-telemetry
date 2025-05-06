#!/bin/bash
set -e
if [ $# -eq 0 ]; then
  echo "Import logs from S3 into local VictoriaLogs for interactive querying."
  echo "Examples:"
  echo "import date=2025-04-25"
  echo "import date=2025-04-25/hour=12"
  echo "import *"
  exit 1
fi

dir=/import
mkdir -p "$dir"
trap 'rm -rf "$dir"' EXIT

api() { curl -sS -H "Authorization: ${ACCESS_TOKEN?}" http://_api.internal:4280/v1/$@; }
org=$(api "apps/$FLY_APP_NAME" | jq -r .organization.id)

s5cmd --log error cp -f --sp "s3://fly-app-logs/logs/org_id=$org/$1*.zst" "$dir/"

curl -X POST \
  -H 'Content-Type: application/stream+json' \
  -H "Content-Encoding: zstd" \
  -H 'VL-Stream-Fields: fly.app.name,fly.region,fly.app.instance' \
  -H 'VL-Time-Field: timestamp' \
  -H 'VL-Msg-Field: message' \
  $(printf -- '-T %q http://localhost:9428/insert/jsonline ' "$dir/*.zst")
  