#!/bin/bash

set -e

REPO=("DNSCrypt/dnscrypt-proxy")

for i in ${REPO[@]}; do

	GIT_URL="https://github.com/${i}/releases/latest"
	VERSION+=($(curl -Ls -o /dev/null -w %{url_effective} ${GIT_URL} | sed -e 's@.*/@@' | tr -d v))

done

sudo docker build -t tabletseeker/whonix_builder:latest \
--build-arg DNSCRYPT_VER=${VERSION[0]} \
--build-arg APT_CACHER_NG_VER=3.7.4-1+b2 \
--build-arg APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
--build-arg APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng .
