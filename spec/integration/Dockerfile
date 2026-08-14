# Test image for `rake spec:integration:docker`.
#
# The integration recipes exercise the service resource, which needs a working
# init system inside the container. The official ubuntu images ship without
# systemd, so install it here and boot the container with /sbin/init.
ARG BASE_IMAGE=ubuntu:noble
FROM ${BASE_IMAGE}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y systemd systemd-sysv dbus && \
    rm -rf /var/lib/apt/lists/*

CMD ["/sbin/init"]
