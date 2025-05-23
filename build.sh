#!/bin/bash

set -e

sudo docker build -t tabletseeker/whonix_builder:latest \
--build-arg APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
--build-arg APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng .
