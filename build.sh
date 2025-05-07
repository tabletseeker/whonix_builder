#!/bin/bash

set -e

REPO=("DNSCrypt/dnscrypt-proxy")

for i in ${REPO[@]}; do

	GIT_URL="https://github.com/${i}/releases/latest"
	VERSION+=($(curl -Ls -o /dev/null -w %{url_effective} ${GIT_URL} | sed -e 's@.*/@@' | tr -d v))

done

sudo docker build -t tabletseeker/whonix_builder:latest --build-arg DNSCRYPT_VER=${VERSION[0]} .
