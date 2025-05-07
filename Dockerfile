FROM debian:bookworm AS baseimage

ARG DNSCRYPT_VER

	### enable https sources ###
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates && \
	sed -i "s|http|https|g" /etc/apt/sources.list.d/debian.sources && \
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
 	wget -qO- https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_VER}/dnscrypt-proxy-linux_x86_64-${DNSCRYPT_VER}.tar.gz | \
 	tar --strip-components 1 -xvz -C /usr/bin linux-x86_64/dnscrypt-proxy && \
 	mkdir -p /etc/dnscrypt-proxy /var/cache/dnscrypt-proxy /lib/systemd/system/apt-cacher-ng.service.d

FROM baseimage

COPY systemd_init.sh starter.sh 50_user.conf /
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY public-resolvers.md public-resolvers.md.minisig /var/cache/dnscrypt-proxy
COPY dnscrypt-proxy.service /usr/lib/systemd/system/dnscrypt-proxy.service

VOLUME [ "/home/user" ]

ENTRYPOINT ["/systemd_init.sh","/starter.sh"]
