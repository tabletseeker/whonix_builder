#!/bin/bash

set -e

SERVICES=("apt-cacher-ng" "dnscrypt-proxy")
LOG_DIR="${HOME}/logs"

[ ! ${CONNECTION} = "onion" ] || SERVICES+=("tor")

[ -d ${LOG_DIR} ] || { mkdir -p ${LOG_DIR}; chown -R ${USER}:${USER} ${LOG_DIR}; }

systemctl restart ${SERVICES[@]}

echo 'Waiting for services to start...'
sleep 5

systemctl status ${SERVICES[@]}

exec "$@"
