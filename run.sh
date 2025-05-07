#!/bin/bash

set -e

latest_ver() {

TAG=$(curl -s https://api.github.com/repos/Whonix/derivative-maker/tags | jq '.[]' |  jq -r '.name | select(test("developer|stable"))' | head -1)
TBB=$(curl -s https://aus1.torproject.org/torbrowser/update_3/release/download-linux-x86_64.json | jq -r '.version')

}

VOLUME="$HOME/whonix-builder"
IMG="tabletseeker/whonix-builder"
TAG=""
TBB=""
LATEST=true
${LATEST} && latest_ver

[ -d ${VOLUME} ] || { mkdir -p ${VOLUME};
sudo chown -R 1000:1000 ${VOLUME};
sudo chmod -R 700 ${VOLUME}; }

sudo docker run --name whonix-builder -it --rm --privileged \
	--env "TAG=${TAG}" \
	--env "TBB_VERSION=${TBB}" \
	--env 'FLAVOR=whonix-gateway-cli whonix-workstation-cli' \
	--env 'TARGET=raw' \
	--env 'ARCH=amd64' \
	--env 'REPO=true' \
	--env 'TYPE=vm' \
	--env 'CLEAN=true' \
	--env 'APT_ONION=false' \
	--volume ${VOLUME}:/home/user \
	--dns 127.0.2.1 ${IMG}
