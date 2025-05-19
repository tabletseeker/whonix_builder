FROM debian:trixie-slim AS dnscrypt

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y dnscrypt-proxy

FROM debian:bookworm-slim AS baseimage

ENV USER=user \
HOME=/home/user \
UID=1000 \
GID=1000 \
APT_CACHER_USER=apt-cacher-ng
ARG APT_CACHER_NG_VER \
APT_CACHER_NG_CACHE_DIR \
APT_CACHER_NG_LOG_DIR

RUN apt-get update && apt-get install --no-install-recommends -y apt-transport-https ca-certificates && \
	### enable https sources ###
	sed -i "s|http|https|g" /etc/apt/sources.list.d/debian.sources && \
	apt-get update && apt-get install --no-install-recommends -y git \
	time curl lsb-release fakeroot dpkg-dev fasttrack-archive-keyring \
	apt-utils wget procps gpg gpg-agent debian-keyring sudo adduser torsocks tor apt-transport-tor safe-rm && \
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

LABEL maintainer="tabletseeker"
LABEL org.label-schema.description="Containerization of Whonix/derivative-maker"
LABEL org.label-schema.name="whonix_builder"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-url="https://github.com/tabletseeker/whonix_builder"

COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY public-resolvers.md public-resolvers.md.minisig /var/cache/dnscrypt-proxy
COPY acng.conf /etc/apt-cacher-ng/acng.conf
COPY torrc /etc/tor/torrc
COPY --from=dnscrypt /usr/sbin/dnscrypt-proxy /usr/bin/dnscrypt-proxy

VOLUME ["${HOME}","${APT_CACHER_NG_CACHE_DIR}"]

USER ${USER}

CMD ["/bin/bash", "-c", "/usr/bin/entrypoint.sh"]
