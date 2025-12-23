ARG BUILD_FROM
FROM $BUILD_FROM

# Build Argument for Branch (Default: main)
ARG BRANCH=Docker

# Install requirements for add-on + git to clone the app
RUN \
    apk add --no-cache \
    python3 \
    py3-pip \
    jq \
    git \
    gcc \
    g++ \
    gfortran \
    musl-dev \
    jpeg-dev \
    zlib-dev \
    libffi-dev \
    alsa-lib-dev \
    portaudio-dev \
    ffmpeg \
    cargo \
    rust \
    openblas-dev \
    lapack-dev

WORKDIR /app

# Clone the latest Development code from GitHub
RUN git clone -b ${BRANCH} https://github.com/AnshulJ999/SyncLyrics.git .

# Remove Desktop/Windows dependencies that break Headless Linux
RUN sed -i '/winsdk/d' requirements.txt && \
    sed -i '/pywin32/d' requirements.txt && \
    sed -i '/pystray/d' requirements.txt && \
    sed -i '/desktop-notifier/d' requirements.txt && \
    echo "spotipy" >> requirements.txt

# Remove conflicting system Python packages (Alpine may ship old Quart 0.18.x)
RUN apk del py3-quart py3-werkzeug py3-flask py3-blinker 2>/dev/null || true

# Note: The main SyncLyrics codebase now has native support for HAOS persistence
# via environment variables (SYNCLYRICS_LYRICS_DB, SYNCLYRICS_ALBUM_ART_DB, etc.)
# No patching needed - the run.sh script exports these variables and the app uses them directly

# Install Python dependencies
RUN pip3 install --no-cache-dir --upgrade -r requirements.txt --break-system-packages

# Copy run script (Local override if needed, or use the one from repo if you commit it)
COPY run.sh /run.sh
RUN tr -d '\r' < /run.sh > /run.sh.tmp && mv /run.sh.tmp /run.sh && chmod a+x /run.sh

CMD [ "/run.sh" ]
