FROM debian:bookworm AS baseimage

	### enable https sources ###
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates && \
	echo "deb https://deb.debian.org/debian bookworm main contrib non-free-firmware" > /etc/apt/sources.list && \
	rm -f /etc/apt/sources.list.d/debian.sources && \
	apt-get update && apt-get install -y systemd systemd-sysv dbus dbus-user-session git \
	time curl lsb-release fakeroot dpkg-dev fasttrack-archive-keyring \
	apt-utils wget procps debian-keyring sudo adduser torsocks tor apt-transport-tor && \
	### apt-cacher-ng ###	
	echo no | apt-get install -y apt-cacher-ng && \	
	chmod 777 /var/cache/apt-cacher-ng && \
	### clean up ###
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/* && \
	rm -f /lib/systemd/system/multi-user.target.wants/* && \
	rm -f /etc/systemd/system/*.wants/* && \
	rm -f /lib/systemd/system/local-fs.target.wants/* && \
	rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
	rm -f /lib/systemd/system/basic.target.wants/* && \
	rm -f /lib/systemd/system/anaconda.target.wants/* && \
	rm -f /lib/systemd/system/plymouth* && \
	rm -f /lib/systemd/system/systemd-update-utmp* && \
	### user account ###
	adduser --quiet --disabled-password --home /home/user --gecos 'user,,,,' user && \
	echo "user:super" | chpasswd && \
	sudo adduser user sudo && \
	echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR=tee visudo -f /etc/sudoers.d/dist-build-sudo-passwordless >/dev/null && \	
	### setup dnscrypt-proxy ###
 	wget https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.5/dnscrypt-proxy-linux_x86_64-2.1.5.tar.gz -O /tmp/dnscrypt-proxy.tar.gz && \
	tar xvf /tmp/*.tar.gz -C /tmp && cp /tmp/linux-x86_64/dnscrypt-proxy /usr/bin/dnscrypt-proxy && rm -rf /tmp/* && mkdir -p \
	/etc/dnscrypt-proxy /var/cache/dnscrypt-proxy /lib/systemd/system/apt-cacher-ng.service.d

FROM baseimage

ENV WHONIX_TAG="17.2.0.7-stable"
ENV TBB_VERSION="13.5.1"
ENV FLAVOR_GW=""
ENV FLAVOR_WS=""
ENV TARGET="raw"
ENV ARCH="amd64"
ENV REPO="true"
ENV TYPE="vm"
ENV CLEAN="true"
ENV APT_ONION="false"
ENV OPTS=""

COPY systemd_init.sh starter.sh 50_user.conf /
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY public-resolvers.md public-resolvers.md.minisig /var/cache/dnscrypt-proxy
COPY dnscrypt-proxy.service /usr/lib/systemd/system/dnscrypt-proxy.service

VOLUME [ "/home/user" ]

ENTRYPOINT ["/systemd_init.sh","/starter.sh"]
