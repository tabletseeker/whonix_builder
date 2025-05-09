#!/bin/bash

set -e

latest_ver() {

TAG=$(curl -s https://api.github.com/repos/Whonix/derivative-maker/tags | jq '.[]' |  jq -r '.name | select(test("developer|stable"))' | head -1)
TBB=$(curl -s https://aus1.torproject.org/torbrowser/update_3/release/download-linux-x86_64.json | jq -r '.version')

}

VOLUME="$HOME/whonix_builder_mnt"
IMG="tabletseeker/whonix_builder"
TAG="17.3.9.2-developers-only"
TBB="14.5.1"
OPTS=""
LATEST=true

[ -d ${VOLUME} ] || { mkdir -p ${VOLUME};
sudo chown -R 1000:1000 ${VOLUME};
sudo chmod -R 700 ${VOLUME}; }

lsmod | grep -q "loop" || sudo modprobe loop dm-mod

${LATEST} && latest_ver || true

sudo docker run --name whonix_builder -it --rm --privileged \
	--env "TAG=${TAG}" \
	--env "TBB_VERSION=${TBB}" \
	--env 'FLAVOR=whonix-gateway-cli whonix-workstation-cli' \
	--env 'TARGET=qcow2' \
	--env 'ARCH=amd64' \
	--env 'REPO=false' \
	--env 'TYPE=vm' \
	--env 'CLEAN=false' \
 	--env "OPTS=${OPTS}" \
	--env 'APT_ONION=false' \
	--volume ${VOLUME}:/home/user \
	--dns 127.0.2.1 ${IMG}
