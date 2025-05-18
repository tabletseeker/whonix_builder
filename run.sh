#!/bin/bash

set -e

latest_version() {

[ ! -z ${TAG} ] || TAG=$(curl -s https://api.github.com/repos/Whonix/derivative-maker/tags | jq '.[]' |  jq -r '.name | select(test("([0-9.]+-(developers|stable))"))' | head -1)
[ ! -z ${TOR} ] || TOR=$(curl -s https://aus1.torproject.org/torbrowser/update_3/release/download-linux-x86_64.json | jq -r '.version')

}

volume_check() {

[ -d ${1} ] || { mkdir -p "${1}"; sleep .1; \
sudo chown -R ${2} ${1}; \
sudo chmod -R ${3} ${1}; }

}

for i in "$@"; do
	
	case $i in

	-t|--tag)
	TAG=${2}
	shift 2
	;;
	-o|--onion)
	TOR=${2}
	shift 2
	;;
	-*|--*)
	echo "Unknown option $i"
	exit 1
	;;
	*)
	;;
	
	esac

done

BUILDER_VOLUME="$HOME/whonix_builder_mnt"
CACHER_VOLUME="$HOME/apt_cacher_mnt"
IMG="tabletseeker/whonix_builder"

volume_check "${BUILDER_VOLUME}" '1000:1000' '700'
volume_check "${CACHER_VOLUME}" '101:102' '777'
latest_version

sudo modprobe -a loop dm-mod

sudo docker run --name whonix_builder -it --rm --privileged \
	--env "TAG=${TAG}" \
	--env "tbb_version=${TOR}" \
	--env 'FLAVOR=whonix-gateway-cli whonix-workstation-cli' \
	--env 'TARGET=qcow2' \
	--env 'ARCH=amd64' \
	--env 'TYPE=vm' \
	--env 'CONNECTION=clearnet' \
	--env 'CLEAN=false' \
	--env 'REPO=false' \
 	--env 'OPTS=' \
	--env 'REPO_PROXY=http://127.0.0.1:3142' \
	--env 'APT_CACHER_ARGS=' \
	--volume ${BUILDER_VOLUME}:/home/user \
	--volume ${CACHER_VOLUME}:/var/cache/apt-cacher-ng \
	--dns 127.0.2.1 ${IMG}
