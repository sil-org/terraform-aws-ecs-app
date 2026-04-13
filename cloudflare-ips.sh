#!/usr/bin/env bash

# NOTE: this didn't work without jq because the external data source expects the result to be a map
# with string keys and string values. The API response is more complex.

set -e

curl --silent --fail 'https://api.cloudflare.com/client/v4/ips' | jq '{
  ipv4_cidrs: (.result.ipv4_cidrs | join(",")),
  ipv6_cidrs: (.result.ipv6_cidrs | join(","))
}'
