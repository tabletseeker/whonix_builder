#!/bin/bash

set -e

SERVICES=("apt-cacher-ng" "dnscrypt-proxy")

[ ! ${CONNECTION} = "onion" ] || SERVICES+=("tor")

systemctl restart ${SERVICES[@]}

echo 'Waiting for services to start...'
sleep 5

systemctl status ${SERVICES[@]}

exec "$@"
