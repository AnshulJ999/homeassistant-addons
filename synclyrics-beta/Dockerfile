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

WORKDIR /app

# Install build dependencies (will be discarded in final stage)
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        g++ \
        musl-dev \
        cargo \
        rust \
        openblas-dev \
        jpeg-dev \
        zlib-dev \
        libffi-dev

# Install runtime dependencies that are also needed for building
RUN apk add --no-cache \
        python3 \
        py3-pip \
        git

# Clone SyncLyrics from GitHub (branch specified by workflow)
RUN git clone -b ${BRANCH} --depth 1 https://github.com/AnshulJ999/SyncLyrics.git .

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

# Set PYTHONPATH so Python finds the installed packages
ENV PYTHONPATH=/install

# Copy application code from builder
COPY --from=builder /app /app

# Copy run script
COPY run.sh /run.sh
RUN tr -d '\r' < /run.sh > /run.sh.tmp && mv /run.sh.tmp /run.sh && chmod a+x /run.sh

CMD [ "/run.sh" ]
