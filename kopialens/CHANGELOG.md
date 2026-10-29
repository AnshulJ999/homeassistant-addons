# Changelog

## [1.0.0] - 2026-10-30

KopiaLens 1.0 is the first public release: a companion app for [Kopia](https://kopia.io) that shows the real size of everything in your repository, finds the files you never meant to keep, and removes them from every snapshot that holds them (Pro), with an optional dry run first.

### What it does

- See where the space goes: every backed-up folder with its real cost after deduplication.
- Find any file in any snapshot, with every version of it.
- Rank snapshots by how much deleting them would free.
- Catch the folders that rewrite themselves on every backup.
- Browse any snapshot like a disk; restore, download or mount what you need.
- Try a retention policy before you use it, and write exclusions that do what you meant.
- Run backups on a schedule, beside KopiaUI and the kopia command line or on its own (kopia is included).
- Remove files and folders from existing snapshots (Pro).

### Free and Pro

Everything KopiaLens shows you is free, with no time limit. Pro adds the actions that remove data from inside your backups: [kopialens.com/pricing](https://kopialens.com/pricing).

### Downloads

Windows (installer and portable zip), macOS (Apple silicon, less tested so far), Linux (AppImage, .deb, .rpm; x64 and arm64), Docker (amd64, arm64) and a Home Assistant add-on. Kopia 0.23.1 is included. Install steps: [kopialens.com/download](https://kopialens.com/download). Checksums are in `SHA256SUMS.txt`.

### Before you install

The Windows and macOS apps aren't code-signed, so Windows shows a SmartScreen warning and macOS blocks the first open. The [download page](https://kopialens.com/download) shows how to get past both.

### Privacy

Nothing in your repository changes unless you start an action. No file names, paths or backup contents leave your computer. A daily update check and anonymous usage stats can each be turned off in **Settings > Updates** ([what is sent](https://kopialens.com/docs/usage-stats)).

❤️ KopiaLens is built on Kopia, and wouldn't exist without it. Thank you to the Kopia team and contributors. KopiaLens is an independent app for Kopia, not affiliated with or endorsed by the Kopia project.
