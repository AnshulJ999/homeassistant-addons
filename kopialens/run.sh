#!/bin/sh
# Home Assistant add-on start: the add-on's options (/data/options.json) become KopiaLens's
# environment, then the release image's own entrypoint starts the server.
set -e
OPTIONS=/data/options.json
opt() { jq -r --arg k "$1" '.[$k] // empty' "$OPTIONS" 2>/dev/null || true; }

# /data is the add-on's own persistent folder (settings, index, kopia's config and cache).
export KOPIALENS_DATA_DIR=/data HOME=/data \
       XDG_CACHE_HOME=/data/kopia-cache XDG_CONFIG_HOME=/data/kopia-config \
       KOPIALENS_HA_INGRESS=1 KOPIALENS_PORT=7123 KOPIALENS_HTTPS=off

# One fixed user@computer for kopia, so snapshots made here continue one history.
KOPIALENS_KOPIA_HOSTNAME="$(opt kopia_hostname)"
KOPIALENS_KOPIA_USERNAME="$(opt kopia_username)"
export KOPIALENS_KOPIA_HOSTNAME="${KOPIALENS_KOPIA_HOSTNAME:-homeassistant}"
export KOPIALENS_KOPIA_USERNAME="${KOPIALENS_KOPIA_USERNAME:-kopialens}"

if [ "$(opt snapshot_mounting)" != "true" ]; then
    export KOPIALENS_HA_MOUNTING=off
fi

exec /usr/local/bin/entrypoint.sh /app/kopialens-server --server
