ARG BUILD_FROM
FROM $BUILD_FROM

# Build Argument for Branch (Default: main)
ARG BRANCH=main

# Install requirements for add-on + git to clone the app
RUN \
    apk add --no-cache \
    python3 \
    py3-pip \
    jq \
    git \
    gcc \
    musl-dev \
    jpeg-dev \
    zlib-dev \
    libffi-dev

WORKDIR /app

# Clone the latest Stable code from GitHub
RUN git clone -b ${BRANCH} https://github.com/AnshulJ999/SyncLyrics.git .

# Remove Desktop/Windows dependencies that break Headless Linux
RUN sed -i '/winsdk/d' requirements.txt && \
    sed -i '/pywin32/d' requirements.txt && \
    sed -i '/pystray/d' requirements.txt && \
    sed -i '/desktop-notifier/d' requirements.txt && \
    echo "spotipy" >> requirements.txt

# Patch Python source files to support HAOS persistent storage via environment variables
# This ensures databases, settings, and cache persist across add-on restarts
RUN python3 << 'EOF'
import os
import re
from pathlib import Path

# Function to patch a file by replacing patterns
def patch_file(filepath, replacements):
    """Apply multiple replacements to a file"""
    if not os.path.exists(filepath):
        print(f"Warning: {filepath} not found, skipping")
        return False
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Patched: {filepath}")
        return True
    else:
        print(f"No changes needed: {filepath}")
        return False

# Patch config.py - Add environment variable support for database and cache directories
# Note: Variable names must match run.sh exports (SYNCLYRICS_LYRICS_DB, SYNCLYRICS_ALBUM_ART_DB)
# This patch is a safety net for older code versions; newer code may already have env var support
config_py = Path("config.py")
if config_py.exists():
    patch_file(config_py, [
        # Replace DATABASE_DIR definition to support env var (matches SYNCLYRICS_LYRICS_DB from run.sh)
        (
            r'(DATABASE_DIR\s*=\s*)ROOT_DIR\s*/\s*STORAGE\.get\("database_dir",\s*"database"\)',
            r'\1Path(os.getenv("SYNCLYRICS_LYRICS_DB", str(ROOT_DIR / STORAGE.get("database_dir", "database"))))'
        ),
        # Also handle if it's already using "lyrics_database" as default
        (
            r'(DATABASE_DIR\s*=\s*)ROOT_DIR\s*/\s*STORAGE\.get\("database_dir",\s*"lyrics_database"\)',
            r'\1Path(os.getenv("SYNCLYRICS_LYRICS_DB", str(ROOT_DIR / STORAGE.get("database_dir", "lyrics_database"))))'
        ),
        # Replace CACHE_DIR definition to support env var
        (
            r'(CACHE_DIR\s*=\s*)ROOT_DIR\s*/\s*STORAGE\.get\("cache_dir",\s*"cache"\)',
            r'\1Path(os.getenv("SYNCLYRICS_CACHE_DIR", str(ROOT_DIR / STORAGE.get("cache_dir", "cache"))))'
        ),
        # Replace ALBUM_ART_DB_DIR definition to support env var (matches SYNCLYRICS_ALBUM_ART_DB from run.sh)
        (
            r'(ALBUM_ART_DB_DIR\s*=\s*)ROOT_DIR\s*/\s*STORAGE\.get\("album_art_db_dir",\s*"album_art_database"\)',
            r'\1Path(os.getenv("SYNCLYRICS_ALBUM_ART_DB", str(ROOT_DIR / STORAGE.get("album_art_db_dir", "album_art_database"))))'
        ),
    ])
    # Ensure os import exists
    with open(config_py, 'r', encoding='utf-8') as f:
        content = f.read()
    if 'import os' not in content and 'from os import' not in content:
        # Add os import after other imports
        content = re.sub(r'(^import\s+\w+)', r'\1\nimport os', content, count=1, flags=re.MULTILINE)
        with open(config_py, 'w', encoding='utf-8') as f:
            f.write(content)

# Patch settings.py - Add environment variable support for settings file path
settings_py = Path("settings.py")
if settings_py.exists():
    patch_file(settings_py, [
        # Replace SETTINGS_FILE definition to support env var
        (
            r'(SETTINGS_FILE\s*=\s*)Path\(__file__\)\.parent\s*/\s*"settings\.json"',
            r'\1Path(os.getenv("SYNCLYRICS_SETTINGS_FILE", str(Path(__file__).parent / "settings.json")))'
        ),
    ])
    # Ensure os import exists
    with open(settings_py, 'r', encoding='utf-8') as f:
        content = f.read()
    if 'import os' not in content and 'from os import' not in content:
        # Add os import
        content = re.sub(r'(^import\s+\w+)', r'\1\nimport os', content, count=1, flags=re.MULTILINE)
        with open(settings_py, 'w', encoding='utf-8') as f:
            f.write(content)

# Patch state_manager.py - Add environment variable support for state file path
# IMPORTANT: Replace "state.json" FIRST, then add STATE_FILE definition to avoid self-reference
state_manager_py = Path("state_manager.py")
if state_manager_py.exists():
    with open(state_manager_py, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    
    # STEP 1: Replace "state.json" references with STATE_FILE variable FIRST
    # (before adding the STATE_FILE definition to avoid self-reference)
    new_content = new_content.replace('path.exists("state.json")', 'path.exists(STATE_FILE)')
    new_content = new_content.replace('path.exists(\'state.json\')', 'path.exists(STATE_FILE)')
    new_content = new_content.replace('os.path.exists("state.json")', 'os.path.exists(STATE_FILE)')
    new_content = new_content.replace('os.path.exists(\'state.json\')', 'os.path.exists(STATE_FILE)')
    new_content = new_content.replace('open("state.json"', 'open(STATE_FILE')
    new_content = new_content.replace('open(\'state.json\'', 'open(STATE_FILE')
    # Handle os.replace(temp_path, "state.json") pattern
    new_content = re.sub(r'os\.replace\(([^,]+),\s*["\']state\.json["\']\)', r'os.replace(\1, STATE_FILE)', new_content)
    # Handle os.remove("state.json") pattern
    new_content = re.sub(r'os\.remove\(["\']state\.json["\']\)', 'os.remove(STATE_FILE)', new_content)
    
    # STEP 2: Now add STATE_FILE definition at the top (after imports)
    if 'STATE_FILE' not in content:  # Check original content, not modified
        # Find the end of imports (look for 'import uuid' line as a common import)
        import_match = re.search(r'(import uuid\n)', new_content)
        if not import_match:
            # Fallback: find any import line
            import_match = re.search(r'(^import\s+\w+\n)', new_content, re.MULTILINE)
        
        if import_match:
            insert_pos = import_match.end()
            # Check if os is already imported
            if 'import os' not in new_content and 'from os import' not in new_content:
                state_file_def = '\nimport os\n# Allow overriding state file location via environment variable for HAOS persistence\nSTATE_FILE = os.getenv("SYNCLYRICS_STATE_FILE", "state.json")\n'
            else:
                state_file_def = '\n# Allow overriding state file location via environment variable for HAOS persistence\nSTATE_FILE = os.getenv("SYNCLYRICS_STATE_FILE", "state.json")\n'
            new_content = new_content[:insert_pos] + state_file_def + new_content[insert_pos:]
        else:
            # Fallback: add at the beginning
            if 'import os' not in new_content:
                new_content = 'import os\n' + new_content
            new_content = '# Allow overriding state file location via environment variable for HAOS persistence\nSTATE_FILE = os.getenv("SYNCLYRICS_STATE_FILE", "state.json")\n\n' + new_content
    
    if new_content != content:
        with open(state_manager_py, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Patched: {state_manager_py}")
    else:
        print(f"No changes needed: {state_manager_py}")

# Note: logging_config.py already has SYNCLYRICS_LOGS_DIR env var support in the main codebase
# No patching needed for logging_config.py

print("Python source files patched for HAOS persistence support")
EOF

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt --break-system-packages

# Copy run script (Local override if needed, or use the one from repo if you commit it)
COPY run.sh /run.sh
RUN tr -d '\r' < /run.sh > /run.sh.tmp && mv /run.sh.tmp /run.sh && chmod a+x /run.sh

CMD [ "/run.sh" ]
