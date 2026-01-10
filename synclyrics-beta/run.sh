#!/usr/bin/with-contenv bashio

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
export LASTFM_API_KEY=$(get_config 'lastfm_api_key')
export FANART_TV_API_KEY=$(get_config 'fanart_tv_api_key')
export AUDIODB_API_KEY=$(get_config 'audiodb_api_key')
export SERVER_PORT=$(get_config 'server_port')
export SPOTIFY_POLLING_FAST_INTERVAL=$(get_config 'spotify_polling_fast_interval')
export SPOTIFY_POLLING_SLOW_INTERVAL=$(get_config 'spotify_polling_slow_interval')

# HTTPS settings
export SERVER_HTTPS_ENABLED=$(get_config 'https_enabled')
export SERVER_HTTPS_PORT=$(get_config 'https_port')

# Database feature toggles
export FEATURES_SAVE_LYRICS_LOCALLY=$(get_config 'save_lyrics_locally')
export FEATURES_ALBUM_ART_DB=$(get_config 'album_art_db')

# Music Assistant Integration
# Note: Variable names must match what config.py expects (key.upper().replace('.', '_'))
export SYSTEM_MUSIC_ASSISTANT_SERVER_URL=$(get_config 'music_assistant_server_url')
export SYSTEM_MUSIC_ASSISTANT_TOKEN=$(get_config 'music_assistant_token')
export SYSTEM_MUSIC_ASSISTANT_PLAYER_ID=$(get_config 'music_assistant_player_id')

if [ -z "$SPOTIFY_CLIENT_ID" ] || [ -z "$SPOTIFY_CLIENT_SECRET" ]; then
    echo "WARNING: Spotify credentials not configured!"
    echo "Spotify features will be unavailable. You can still use other audio sources (Spicetify, Shazam, etc.)."
    echo "To enable Spotify, set spotify_client_id and spotify_client_secret in the add-on configuration."
fi

# Debug and logging configuration
# Note: config.py uses conf() function which expects DEBUG_ENABLED and DEBUG_LOG_LEVEL env vars
if [ "$(get_config 'debug')" == "true" ]; then
    export DEBUG_ENABLED="true"
    export DEBUG_LOG_DETAILED="true"  # Enable detailed debug logging to debug.log file
    # If debug is enabled, override log_level to DEBUG unless explicitly set
    LOG_LEVEL_CONFIG=$(get_config 'log_level')
    if [ -z "$LOG_LEVEL_CONFIG" ] || [ "$LOG_LEVEL_CONFIG" == "null" ]; then
        export DEBUG_LOG_LEVEL="DEBUG"
    else
        export DEBUG_LOG_LEVEL="$LOG_LEVEL_CONFIG"
    fi
else
    export DEBUG_ENABLED="false"
    export DEBUG_LOG_DETAILED="true"
    # Set log level from config (defaults to INFO if not set)
    LOG_LEVEL_CONFIG=$(get_config 'log_level')
    if [ -z "$LOG_LEVEL_CONFIG" ] || [ "$LOG_LEVEL_CONFIG" == "null" ]; then
        export DEBUG_LOG_LEVEL="INFO"
    else
        export DEBUG_LOG_LEVEL="$LOG_LEVEL_CONFIG"
    fi
fi

# Set persistent cache path for Spotify tokens
# addon_config is mapped to /config inside the container (visible to users in File Editor)
export SPOTIPY_CACHE_PATH=$(get_config 'spotify_cache_path')

# All persistent data goes to /config (which is the addon_config folder, visible to users)
# This allows users to browse/edit their lyrics databases, album art, and settings
echo "Using addon_config storage (visible at /addon_configs/synclyrics on host)"

# Ensure base directory exists
mkdir -p "/config"

# Map SyncLyrics internal paths to persistent storage via Environment Variables
# These environment variables will be read by the Python code to use persistent storage
# instead of the default /app directory which is ephemeral
# All paths point to /config (addon_config) so users can see/edit their data

# 1. Settings File - stores user preferences and configuration
export SYNCLYRICS_SETTINGS_FILE="/config/settings.json"

# 2. Databases - store lyrics and album art data (users can browse/edit these JSONs and images)
# Note: Variable names must match what config.py expects (SYNCLYRICS_LYRICS_DB, not SYNCLYRICS_DATABASE_DIR)
export SYNCLYRICS_LYRICS_DB="/config/lyrics_database"
export SYNCLYRICS_ALBUM_ART_DB="/config/album_art_database"
export SYNCLYRICS_SPICETIFY_DB="/config/spicetify_database"

# 3. Cache - temporary files and cached data
export SYNCLYRICS_CACHE_DIR="/config/cache"

# 4. State File - stores UI state and theme preferences
export SYNCLYRICS_STATE_FILE="/config/state.json"

# 5. Logs - application logs for debugging (users can view these)
export SYNCLYRICS_LOGS_DIR="/config/logs"

# 6. SSL Certs - persistent storage so they don't regenerate on every restart
export SYNCLYRICS_CERTS_DIR="/config/certs"

# Ensure all subdirectories exist
mkdir -p "$SYNCLYRICS_LYRICS_DB"
mkdir -p "$SYNCLYRICS_ALBUM_ART_DB"
mkdir -p "$SYNCLYRICS_SPICETIFY_DB"
mkdir -p "$SYNCLYRICS_CACHE_DIR"
mkdir -p "$SYNCLYRICS_LOGS_DIR"
mkdir -p "$SYNCLYRICS_CERTS_DIR"

# SPOTIPY_CACHE_PATH is a file path, so ensure its directory exists
mkdir -p "$(dirname "$SPOTIPY_CACHE_PATH")"

# Log paths for debugging
echo "Settings file: $SYNCLYRICS_SETTINGS_FILE"
echo "Lyrics database directory: $SYNCLYRICS_LYRICS_DB"
echo "Album art database: $SYNCLYRICS_ALBUM_ART_DB"
echo "Cache directory: $SYNCLYRICS_CACHE_DIR"
echo "State file: $SYNCLYRICS_STATE_FILE"
echo "Logs directory: $SYNCLYRICS_LOGS_DIR"
echo "Spotify token cache path: $SPOTIPY_CACHE_PATH"

# Debug: Print environment variables for troubleshooting
echo "=== Environment Variables for Debugging ==="
echo "DEBUG_ENABLED=$DEBUG_ENABLED"
echo "DEBUG_LOG_LEVEL=$DEBUG_LOG_LEVEL"
echo "DEBUG_LOG_DETAILED=$DEBUG_LOG_DETAILED"
echo "SPOTIFY_CLIENT_ID=${SPOTIFY_CLIENT_ID:0:10}..."  # Only show first 10 chars for security
echo "SPOTIFY_CLIENT_SECRET=${SPOTIFY_CLIENT_SECRET:0:10}..."
echo "SERVER_PORT=$SERVER_PORT"
echo "============================================"

# Generate a random secret key for the session if not present
export QUART_SECRET_KEY="ha-secret-$(date +%s)"

# Set Linux defaults
export DESKTOP="Linux"
export PYTHONUNBUFFERED=1

# Run the app
exec python3 sync_lyrics.py
