#!/bin/bash

set -e

systemctl restart apt-cacher-ng.service dnscrypt-proxy.service
[ ! ${CONNECTION} = "onion" ] || systemctl restart tor.service
echo 'Waiting for services to start...'
sleep 5
systemctl status apt-cacher-ng.service dnscrypt-proxy.service
[ ! ${CONNECTION} = "onion" ] || systemctl status tor.service
