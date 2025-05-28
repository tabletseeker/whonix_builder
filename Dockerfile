FROM debian:bookworm-slim AS baseimage

ENV USER=user \
HOME=/home/user

RUN sed -i '0,/bookworm/ s/bookworm/bookworm trixie/' /etc/apt/sources.list.d/debian.sources && \
	apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t bookworm \
	dbus dbus-user-session git time curl lsb-release fakeroot dpkg-dev \
	fasttrack-archive-keyring safe-rm gpg gpg-agent sudo adduser ca-certificates \
	wget apt-transport-https torsocks tor apt-transport-tor dmsetup apt-cacher-ng && \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t trixie dnscrypt-proxy && \
	### user account ###
	adduser --quiet --disabled-password --home /home/${USER} --gecos '${USER},,,,' ${USER} && \
	echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/passwordless_sudo && \
	chmod 440 /etc/sudoers.d/passwordless_sudo && \
	### clean up ###
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/*

FROM baseimage

LABEL maintainer="tabletseeker"
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

ENTRYPOINT ["/usr/bin/entrypoint.sh","/usr/bin/start_services.sh"]

CMD ["/bin/bash", "-c", "/usr/bin/su ${USER} --preserve-environment --session-command '/usr/bin/start_build.sh'"]
