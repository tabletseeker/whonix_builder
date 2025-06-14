#!/bin/bash

set -e

### variables ###
LOG_DIR="${HOME}/logs"
KEY_LOG="${LOG_DIR}/key.log"
GIT_LOG="${LOG_DIR}/git.log"
BUILD_LOG="${LOG_DIR}/build.log"
GIT_URL="https://github.com/Whonix/derivative-maker.git"
read -a FLAVOR <<< "$FLAVOR"
### functions ###
timestamp() { echo -e "\n${1} Time: $(date +'%D|%H:%M:%S')\n" >> ${2}; }
pid_check() { pgrep -f "${1}" > /dev/null; }
lo_clean() { LOOP_DEV=$(sudo losetup -nl | grep -E "(Whonix|Kicksecure).*" | awk '{print $1}'); \
[ -z "${LOOP_DEV}" ] || sudo losetup -d ${LOOP_DEV}; }
build_cmd() { for ((i=0;i<${1};i++)); do timestamp 'Build Start' ${2}; \
lo_clean; \
/home/user/${TAG}/derivative-maker \
--flavor ${FLAVOR[i]} \
--target ${TARGET} \
--arch ${ARCH} \
--type ${TYPE} \
--connection ${CONNECTION} \
--repo ${REPO} \
${OPTS}; timestamp 'Build End' ${2}; done; }
### start apt-cacher-ng ###
pid_check "apt-cacher-ng" || { sudo --non-interactive /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng ${APT_CACHER_ARGS} & }
### start dnscrypt ###
pid_check "dnscrypt-proxy" || { /usr/bin/dnscrypt-proxy --config /etc/dnscrypt-proxy/dnscrypt-proxy.toml & }
### start tor if onion ###
[ ! ${CONNECTION} = "onion" ] || { pid_check "tor" || /usr/bin/tor > /dev/null & }
### create log directory ###
[ -d ${LOG_DIR} ] || mkdir -p ${LOG_DIR}
### sleep init cycle ###
echo -e "Waiting for processes to start...."
sleep 6
### get derivative key ###
[ -f ~/derivative.asc ] || { wget https://www.whonix.org/keys/derivative.asc -O ~/derivative.asc; \
gpg --keyid-format long --import --import-options show-only --with-fingerprint ~/derivative.asc; \
gpg --import ~/derivative.asc; gpg --check-sigs 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA; } 2>&1 | tee ${KEY_LOG}
### clone help-steps ###
timestamp 'Git Start' ${GIT_LOG}
[ -d ~/derivative-maker ] || { mkdir ~/derivative-maker; cd ~/derivative-maker; git init -b master; \
git remote add -f origin ${GIT_URL}; \
git config core.sparseCheckout true; \
cat > .git/info/sparse-checkout << EOF
help-steps/pre
help-steps/colors
help-steps/variables
EOF
git pull origin master; } 2>&1 | tee -a ${GIT_LOG}
### clone latest tag ###
[ -d ~/${TAG} ] || git clone --depth=1 --branch ${TAG} \
--jobs=4 --recurse-submodules --shallow-submodules ${GIT_URL} ~/${TAG} 2>&1 | tee -a ${GIT_LOG}
### git check & verify ###
{ cd ~/${TAG}; git pull; [ ${TAG} = 'master' ] || { git describe; git verify-tag ${TAG}; }; \
git verify-commit ${TAG}^{commit}; git checkout --recurse-submodules ${TAG}; \
git status; } 2>&1 | tee -a ${GIT_LOG}; timestamp 'Git End' ${GIT_LOG}
### execute build command ###
build_cmd ${#FLAVOR[@]} ${BUILD_LOG} 2>&1 | tee -a ${BUILD_LOG}; exec "$@"
