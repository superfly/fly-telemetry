#!/bin/sh
# Import logs from S3 into local VictoriaLogs for interactive querying.
# Examples:
# /import.sh date=2025-04-12
# /import.sh date=2025-04-12/hour=12
# /import.sh *
set -e

if [ $# -eq 0 ]; then
  echo "Usage: import.sh [path]"
  exit 1
fi

path="$1*"

mkdir -p /import
trap 'rm -rf /import' EXIT

api() { curl -sS -H "Authorization: ${ACCESS_TOKEN?}" http://_api.internal:4280/v1/$@; }
org=$(api "apps/$FLY_APP_NAME" | jq -r .organization.id)
s5cmd --log error cp -f --sp "s3://fly-app-logs/logs/org_id=$org/$path" /import/
for i in /import/*.zst; do zstdcat "$i"; echo; done |
  curl -s -X POST -T - -H 'Content-Type: application/stream+json' \
    'http://localhost:9428/insert/jsonline?_stream_fields=fly.app.instance&_time_field=timestamp&_msg_field=message'
