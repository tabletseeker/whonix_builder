FROM debian:bookworm-slim AS baseimage

LABEL maintainer="tabletseeker"
LABEL org.label-schema.description="Containerization of Whonix/derivative-maker"
LABEL org.label-schema.name="whonix_builder"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-url="https://github.com/tabletseeker/whonix_builder"

ENV USER=user \
HOME=/home/user \
GID=1000 \
UID=1000 \
APT_CACHER_USER=apt-cacher-ng
ARG DNSCRYPT_VER \
APT_CACHER_NG_VER \
APT_CACHER_NG_CACHE_DIR \
APT_CACHER_NG_LOG_DIR

RUN apt-get update && apt-get install --no-install-recommends -y apt-transport-https ca-certificates && \
	### enable https sources ###
	sed -i "s|http|https|g" /etc/apt/sources.list.d/debian.sources && \
	apt-get update && apt-get install --no-install-recommends -y git \
	time curl lsb-release fakeroot dpkg-dev fasttrack-archive-keyring \
	apt-utils wget procps gpg gpg-agent debian-keyring sudo adduser torsocks tor apt-transport-tor safe-rm && \
	### dnscrypt-proxy ###
 	wget -qO- https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_VER}/dnscrypt-proxy-linux_x86_64-${DNSCRYPT_VER}.tar.gz | \
 	tar --strip-components 1 -xvz -C /usr/bin linux-x86_64/dnscrypt-proxy && \
	### apt-cacher-ng ###
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y apt-cacher-ng=${APT_CACHER_NG_VER} && \
 	### setup directories ###
  	mkdir -p /etc/dnscrypt-proxy /var/cache/dnscrypt-proxy \
  	/run/apt-cacher-ng ${APT_CACHER_NG_CACHE_DIR} ${APT_CACHER_NG_LOG_DIR} && \
	### setup permissions ###
	chown -R ${APT_CACHER_USER}:${APT_CACHER_USER} /run/apt-cacher-ng \
	${APT_CACHER_NG_LOG_DIR} && \
	chown -R ${APT_CACHER_USER}:0 ${APT_CACHER_NG_CACHE_DIR} && \
	chmod -R 0755 /run/apt-cacher-ng ${APT_CACHER_NG_CACHE_DIR} \
	${APT_CACHER_NG_LOG_DIR} && \
	### user account ###
	adduser --quiet --disabled-password --home /home/${USER} --gecos '${USER},,,,' ${USER} && \
	echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/passwordless_sudo && \
	chmod 440 /etc/sudoers.d/passwordless_sudo && \
	### clean up ###
	apt-get clean autoclean && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

FROM baseimage

COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY public-resolvers.md public-resolvers.md.minisig /var/cache/dnscrypt-proxy
COPY acng.conf /etc/apt-cacher-ng/acng.conf
COPY torrc /etc/tor/torrc

VOLUME ["${HOME}","${APT_CACHER_NG_CACHE_DIR}"]

USER ${USER}

CMD ["/bin/bash", "-c", "/usr/bin/entrypoint.sh"]
