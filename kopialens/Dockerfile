# syntax=docker/dockerfile:1
# The Home Assistant add-on image: the KopiaLens release image (packaging/docker/Dockerfile) plus the
# add-on's start script. The pipeline builds it per arch as ghcr.io/anshulj999/kopialens-ha-{arch}.
# Local build (from this folder):
#   docker build --build-arg BUILD_FROM=kopialens:local -t kopialens-ha:local .
ARG BUILD_FROM=ghcr.io/anshulj999/kopialens:latest
FROM ${BUILD_FROM}
RUN apt-get update && apt-get install -y --no-install-recommends jq && rm -rf /var/lib/apt/lists/*
COPY run.sh /run.sh
RUN chmod 0755 /run.sh

ARG BUILD_VERSION=dev
ARG BUILD_ARCH=amd64
LABEL io.hass.type="addon" io.hass.name="KopiaLens" io.hass.version="${BUILD_VERSION}" io.hass.arch="${BUILD_ARCH}"

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/run.sh"]
