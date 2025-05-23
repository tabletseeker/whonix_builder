FROM debian:bookworm-slim AS baseimage

ENV USER=user \
HOME=/home/user \
APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng

RUN sed -i '0,/bookworm/ s/bookworm/bookworm trixie/' /etc/apt/sources.list.d/debian.sources && \
	apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t bookworm \
	systemd systemd-sysv dbus dbus-user-session git time curl lsb-release fakeroot dpkg-dev \
	fasttrack-archive-keyring apt-utils wget procps gpg gpg-agent debian-keyring sudo adduser \
	apt-transport-https ca-certificates torsocks tor apt-transport-tor dmsetup apt-cacher-ng && \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t trixie dnscrypt-proxy && \
	### user account ###
	adduser --quiet --disabled-password --home /home/${USER} --gecos '${USER},,,,' ${USER} && \
	echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/passwordless_sudo && \
	chmod 440 /etc/sudoers.d/passwordless_sudo && \
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
	rm -f /lib/systemd/system/systemd-update-utmp*

FROM baseimage

LABEL maintainer="derivative-maker"
LABEL org.label-schema.description="Containerization of Whonix/derivative-maker"
LABEL org.label-schema.name="whonix_builder"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-url="https://github.com/tabletseeker/whonix_builder"

COPY entrypoint.sh start_build.sh start_services.sh /usr/bin
COPY acng.conf /etc/apt-cacher-ng/acng.conf
COPY torrc /etc/tor/torrc
COPY dnscrypt-proxy/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY dnscrypt-proxy/dnscrypt-proxy.service /usr/lib/systemd/system/dnscrypt-proxy.service
COPY dnscrypt-proxy/public-resolvers.md dnscrypt-proxy/public-resolvers.md.minisig /var/cache/dnscrypt-proxy/

VOLUME ["${HOME}","${APT_CACHER_NG_CACHE_DIR}"]

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/bin/bash", "-c", "/usr/bin/start_services.sh && /usr/bin/su ${USER} --command '/usr/bin/start_build.sh'"]
