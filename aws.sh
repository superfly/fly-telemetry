#!/bin/sh
cache=~/.aws/cache.json
jq -e '(.Expiration | fromdateiso8601) > now' $cache >/dev/null 2>&1 && { cat $cache; exit 0; }
api() { curl -sS -H "Authorization: ${ACCESS_TOKEN?}" http://_api.internal:4280/v1/$@; }
slug=$(api "apps/$FLY_APP_NAME" | jq -r .organization.slug)
api orgs/"$slug"/tokens/s3_logs -X POST | tee $cache
