"""
Rebuild each add-on's CHANGELOG.md from SyncLyrics' CHANGELOG.md.

Stable and Debian read SyncLyrics `main`; beta reads `development`. Headings are
rewritten from `## [X.Y.Z] - date` to `## X.Y.Z` (beta: `## X.Y.Z-beta`) because Home
Assistant trims the update dialog to new entries by matching `# <version>` exactly.

Usage:
    python sync_changelogs.py                      # fetch from GitHub and write
    python sync_changelogs.py --source FILE --dry-run   # local check, print only
"""
import argparse
import re
import sys
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
RAW_URL = "https://raw.githubusercontent.com/AnshulJ999/SyncLyrics/{branch}/CHANGELOG.md"
HA_HEADER = "<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->"

# add-on folder -> (SyncLyrics branch it builds from, is beta)
VARIANTS = {
    "synclyrics": ("main", False),
    "synclyrics-debian": ("main", False),
    "synclyrics-beta": ("development", True),
}

# Added to the newest section only, so the HA update dialog shows it once
SUPPORT_BLOCK = """☕ **Enjoying SyncLyrics?** It started as a small hobby project so I could get lyrics on my tablet, and somehow grew into this. It's free and made by one person, so if it's earned a spot in your setup, a small contribution would really help me keep building it :)

[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsor-ea4aaa?logo=githubsponsors)](https://github.com/sponsors/AnshulJ999)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-ff5e5b?logo=kofi)](https://ko-fi.com/anshul99)
[![Patreon](https://img.shields.io/badge/Patreon-Join-f96854?logo=patreon)](https://www.patreon.com/AnshulJain)
[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue?logo=paypal)](https://paypal.me/AnshulJain99)"""

HEADING = re.compile(r"^## \[(?P<ver>[^\]]+)\]")
CONFIG_VERSION = re.compile(r'^version:\s*"?([^"\s]+)"?', re.MULTILINE)


def fetch_changelog(branch: str) -> str:
    with urllib.request.urlopen(RAW_URL.format(branch=branch), timeout=30) as resp:
        return resp.read().decode("utf-8")


def split_sections(text: str) -> list[tuple[str, list[str]]]:
    """[(version, body_lines)] in file order; anything before the first heading is dropped."""
    sections: list[tuple[str, list[str]]] = []
    for line in text.splitlines():
        match = HEADING.match(line)
        if match:
            sections.append((match.group("ver").strip(), []))
        elif sections:
            sections[-1][1].append(line)
    return sections


def ha_version(version: str, beta: bool) -> str:
    # Pre-release versions (e.g. 2.1.1-beta) already carry a suffix
    return f"{version}-beta" if beta and "-" not in version else version


def render(sections: list[tuple[str, list[str]]], beta: bool, addon_version: str) -> str:
    released = {ha_version(v, beta) for v, _ in sections if v.lower() != "unreleased"}
    lines = [HA_HEADER]
    for version, body in sections:
        if version.lower() == "unreleased":
            # Only a beta build of not-yet-released work gets the Unreleased notes
            if not beta or addon_version in released:
                continue
            label = addon_version
        else:
            label = ha_version(version, beta)
        lines.append(f"## {label}")
        if len(lines) == 2:
            body = body[:]
            while body and not body[-1].strip():
                body.pop()
            body += ["", SUPPORT_BLOCK, ""]
        lines.extend(body)
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--source", type=Path, help="Read this CHANGELOG.md instead of fetching from GitHub")
    parser.add_argument("--dry-run", action="store_true", help="Print results instead of writing files")
    args = parser.parse_args()

    cache: dict[str, str] = {}
    for folder, (branch, beta) in VARIANTS.items():
        config_text = (REPO_ROOT / folder / "config.yaml").read_text(encoding="utf-8")
        match = CONFIG_VERSION.search(config_text)
        addon_version = match.group(1) if match else ""

        if args.source:
            source_text = args.source.read_text(encoding="utf-8")
        else:
            if branch not in cache:
                cache[branch] = fetch_changelog(branch)
            source_text = cache[branch]

        content = render(split_sections(source_text), beta, addon_version)
        if f"## {addon_version}\n" not in content:
            # Source is stale (raw.githubusercontent caches ~5 min) or missing this version:
            # keep the existing file rather than overwrite a correct one with older content.
            print(f"::warning::{folder}: no '## {addon_version}' section in SyncLyrics {branch} CHANGELOG.md, skipped")
            continue

        target = REPO_ROOT / folder / "CHANGELOG.md"
        if args.dry_run:
            print(f"===== {folder} (version {addon_version}, from {branch}) =====")
            print(content)
            continue
        if target.read_text(encoding="utf-8") != content:
            target.write_text(content, encoding="utf-8", newline="\n")
            print(f"Updated {folder}/CHANGELOG.md")
        else:
            print(f"{folder}/CHANGELOG.md already in sync")
    return 0


if __name__ == "__main__":
    sys.exit(main())
