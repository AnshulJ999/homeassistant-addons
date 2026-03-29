# SyncLyrics BETA Home Assistant Add-on
# Multi-stage build for optimized image size
# https://github.com/AnshulJ999/SyncLyrics

# ============================================
# STAGE 1: Builder
# Install build tools, compile Python packages
# ============================================
ARG BUILD_FROM
FROM $BUILD_FROM AS builder

# Default to development branch for beta, but can be overridden via workflow
ARG BRANCH=development

# Cache buster - changes every build to force fresh git clone
# Without this, Docker reuses cached git clone results with stale code
ARG CACHEBUST=1

WORKDIR /app

# Install build dependencies (will be discarded in final stage)
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        g++ \
        musl-dev \
        cargo \
        rust \
        pkgconf \
        openblas-dev \
        jpeg-dev \
        zlib-dev \
        libffi-dev \
        alsa-lib-dev \
        portaudio-dev

# Install runtime dependencies that are also needed for building
RUN apk add --no-cache \
        python3 \
        py3-pip \
        git

# Clone SyncLyrics from GitHub (branch specified by workflow)
# The CACHEBUST arg invalidates cache for this layer and all subsequent layers
# This ensures we always get the latest code from the repo
RUN echo "Cache bust: ${CACHEBUST}" && \
    git clone -b ${BRANCH} --depth 1 https://github.com/AnshulJ999/SyncLyrics.git .

# Remove Windows/desktop dependencies not needed for headless Linux
RUN sed -i '/winsdk/d' requirements.txt && \
    sed -i '/pywin32/d' requirements.txt && \
    sed -i '/pystray/d' requirements.txt && \
    sed -i '/desktop-notifier/d' requirements.txt && \
    sed -i '/pyinstaller/d' requirements.txt && \
    sed -i '/matplotlib/d' requirements.txt && \
    sed -i '/scipy/d' requirements.txt && \
    sed -i '/psutil/d' requirements.txt && \
    echo "spotipy" >> requirements.txt

# Remove conflicting system Python packages
RUN apk del py3-quart py3-werkzeug py3-flask py3-blinker 2>/dev/null || true

# Install Python dependencies to a neutral /install folder (version-agnostic)
# This avoids hardcoding Python version in COPY paths
RUN pip3 install --no-cache-dir --upgrade --target=/install -r requirements.txt --break-system-packages

# ============================================
# STAGE 2: Runtime
# Lean image with only runtime dependencies
# ============================================
FROM $BUILD_FROM

WORKDIR /app

# Disable jemalloc preload for RPi5 / 16K-page-size compatibility (HAOS 17+).
# HA base images preload jemalloc (compiled for 4K pages) via LD_PRELOAD at s6 init time.
# On RPi5 (Cortex-A76, 16K kernel pages), jemalloc aborts immediately, crashing every
# child process (including jq) before Python ever starts. DISABLE_JEMALLOC=true tells
# s6-overlay to skip the LD_PRELOAD setup, falling back to the system allocator.
# Safe for all platforms — performance impact is negligible for a lyrics server.
# ENV DISABLE_JEMALLOC=true

# Install runtime dependencies only (no build tools)
# Note: libjpeg-turbo, zlib, libffi, openblas are needed at runtime
RUN apk add --no-cache \
        python3 \
        py3-pip \
        jq \
        ffmpeg \
        alsa-lib \
        portaudio \
        libjpeg-turbo \
        zlib \
        libffi \
        openblas

# Copy Python packages from builder (version-agnostic)
COPY --from=builder /install /install

# Set PYTHONPATH so Python finds the installed packages (append to existing)
ENV PYTHONPATH="/install${PYTHONPATH:+:$PYTHONPATH}"

# Copy application code from builder
COPY --from=builder /app /app

# Inject version from workflow (config.yaml is source of truth for HA add-ons)
# If VERSION not passed, the cloned version.py is preserved as fallback
ARG VERSION
RUN if [ -n "${VERSION}" ]; then echo "VERSION = \"${VERSION}\"" > /app/version.py; fi

# Copy run script
COPY run.sh /run.sh
RUN tr -d '\r' < /run.sh > /run.sh.tmp && mv /run.sh.tmp /run.sh && chmod a+x /run.sh

CMD [ "/run.sh" ]
