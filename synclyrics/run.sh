#!/bin/bash
set -e

echo "Starting SyncLyrics..."

# Path to Home Assistant Options
CONFIG_PATH="/data/options.json"

# Helper function to read config using jq
function get_config {
    jq --raw-output ".$1 // empty" $CONFIG_PATH
}

# Read config variables
export SPOTIFY_CLIENT_ID=$(get_config 'spotify_client_id')
export SPOTIFY_CLIENT_SECRET=$(get_config 'spotify_client_secret')
export SPOTIFY_REDIRECT_URI=$(get_config 'spotify_redirect_uri')
export SPOTIFY_BASE_URL=$(get_config 'spotify_base_url')
export SERVER_PORT=$(get_config 'server_port')

# Generate a random secret key for the session
export QUART_SECRET_KEY="ha-secret-$(date +%s)"

# Set Linux defaults
export DESKTOP="Linux"
export PYTHONUNBUFFERED=1

# Run the app
python3 sync_lyrics.py
