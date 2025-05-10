#!/bin/bash

set -e

### variables ###
KEY_LOG="~/logs/key.log"
GIT_LOG="~/logs/git.log"
BUILD_LOG="~/logs/build.log"
read -a FLAVOR <<< "$FLAVOR"

### functions ###
timestamp() { echo -e "\n${1} Time: $(date +'%H:%M:%S')\n" >> ${2}; }
build_cmd() { for ((i=0;i<${1};i++)); do timestamp 'Build Start' ${2}; ${3}; done; }
FUNC_1=$(declare -f timestamp)
FUNC_2=$(declare -f build_cmd)

### if APT_ONION true ###
${APT_ONION} && { ONION="--connection onion" && mv /50_user.conf /lib/systemd/system/apt-cacher-ng.service.d/50_user.conf && \
{ cat >> /etc/apt-cacher-ng/acng.conf << EOF
PassThroughPattern: .*
BindAddress: localhost
SocketPath: /run/apt-cacher-ng/socket
Port:3142
Proxy: http://127.0.0.1:3142
AllowUserPorts: 0
EOF
} && echo -e 'Acquire::http { Proxy "http://127.0.0.1:3142"; }\nAcquire::BlockDotOnion "false";' > /etc/apt/apt.conf.d/30user && \
systemctl daemon-reload && systemctl start tor.service && \
systemctl restart apt-cacher-ng.service && sleep 1; } || true

### start dnscrypt service ###
sudo -u user /bin/bash -c '{ mkdir -p ~/logs && sudo systemctl start dnscrypt-proxy.service; sleep 1; }'

### start whonix build ###
sudo -u user /bin/bash -c "$FUNC_1; $FUNC_2; [ -f ~/derivative.asc ] || { wget https://www.whonix.org/keys/derivative.asc -O ~/derivative.asc && \
gpg --keyid-format long --import --import-options show-only --with-fingerprint ~/derivative.asc && \
gpg --import ~/derivative.asc && gpg --check-sigs 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA; } 2>&1 | tee ${KEY_LOG}; \

timestamp 'Git Start' ${GIT_LOG}; [ -d ~/derivative-maker ] || git clone --depth=1 --branch ${TAG} \
--jobs=4 --recurse-submodules --shallow-submodules https://github.com/Whonix/derivative-maker.git ~/derivative-maker 2>&1 | tee -a ${GIT_LOG}; \

{ cd ~/derivative-maker; git pull && git verify-tag ${TAG} && \
git verify-commit ${TAG}^{commit} && git checkout --recurse-submodules ${TAG} && \
git describe && git status; } 2>&1 | tee -a ${GIT_LOG} && timestamp 'Git End' ${GIT_LOG} && \

${CLEAN} && rm -rf ~/derivative-binary || true; \
tbb_version=${TBB_VERSION}; build_cmd ${#FLAVOR[@]} ${BUILD_LOG} '/home/user/derivative-maker/derivative-maker --flavor ${FLAVOR[i]} 
--target ${TARGET} --arch ${ARCH} --repo ${REPO} --type ${TYPE} ${ONION} ${OPTS}' 2>&1 | tee -a ${BUILD_LOG}"
