# SyncLyrics Home Assistant Add-on (Debian Version)
# Multi-stage build for optimized image size
# https://github.com/AnshulJ999/SyncLyrics
#
# This Debian-based version uses glibc instead of musl,
# providing better compatibility with numpy/OpenBLAS on server CPUs.

# ============================================
# STAGE 1: Builder
# Install build tools, compile Python packages
# ============================================
ARG BUILD_FROM
FROM $BUILD_FROM AS builder

# Default to main branch, can be overridden via workflow
ARG BRANCH=main

# Cache buster - changes every build to force fresh git clone
# Without this, Docker reuses cached git clone results with stale code
ARG CACHEBUST=1

WORKDIR /app

# Install build dependencies (will be discarded in final stage)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ \
        cargo \
        rustc \
        pkg-config \
        libopenblas-dev \
        libjpeg-dev \
        zlib1g-dev \
        libffi-dev \
        libasound2-dev \
        portaudio19-dev \
        python3 \
        python3-pip \
        python3-venv \
        git \
    && rm -rf /var/lib/apt/lists/*

# Clone SyncLyrics from GitHub
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
ENV DISABLE_JEMALLOC=true

# Install runtime dependencies only (no build tools)
# Note: libjpeg, zlib, libffi, openblas are needed at runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        jq \
        ffmpeg \
        libasound2 \
        libportaudio2 \
        libjpeg62-turbo \
        zlib1g \
        libffi8 \
        libopenblas0 \
    && rm -rf /var/lib/apt/lists/*

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
