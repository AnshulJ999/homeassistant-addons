# Changelog

Every KopiaLens release, newest first. The release pipeline copies a version's section into its GitHub release notes, so each heading must read `## [X.Y.Z] - YYYY-MM-DD`. Sections use `### Added`, `### Changed`, `### Fixed` (and `### Important` above them when something needs the reader's attention). One short line per change, in the user's words. 

## [1.1.0] - 2026-11-23

### Important

- macOS, and Linux outside Debian and Ubuntu: earlier versions couldn't check for updates or activate a licence, so they never showed an update notice. Download 1.1.0 by hand once; later updates arrive in the app as usual.

### Added

- Intel Macs: a separate macOS download next to the Apple silicon one.
- Backblaze on a Mac: KopiaLens reads Backblaze Personal Backup's data on macOS, startup disk and external drives.
- Backblaze from another computer: point KopiaLens at a shared Backblaze data folder (bzdata) from Windows, a Mac, Docker or Home Assistant. Setup offers it when Backblaze isn't on this computer, and a folder change applies without a restart.
- Backblaze Health shows the installed Backblaze version and says when a newer one is out.
- Backblaze Health notes when Backblaze lost track of files it had already uploaded and queued them again, from Backblaze's own records. The Uploaded history keeps those days.
- Backblaze Health notes when Backblaze's server asked for files to be uploaded again.
- Backblaze and Kopia search accept `*` as a wildcard. Other typed text, including `_` and `%`, matches as typed.
- Folder icons in more Backblaze tables, and short tooltips on Backblaze's own terms.

### Changed

- The Backblaze Queue shows when Backblaze last updated it.
- Import archived history is hidden; it needed a hand-copied log folder.
- Backblaze Health's checks are listed under a "?" next to its summary.
- Backblaze Sessions shows one row per backup run: when it started, how long it took and what it uploaded.
- Backblaze screens follow the light and dark themes.
- When Backblaze's data folder is there but can't be read (on a Mac, usually a privacy setting), setup says so and how to allow it, instead of "Backblaze wasn't found".
- Diagnostics bundles now list each Backblaze drive's scan file and whether it's indexed, and the state of Backblaze's upload queue.
- Docker: the example compose file uses a full path for `/config`, so it works in Portainer, and leaves snapshot mounting off, so it starts on hosts without FUSE.

### Fixed

- macOS and Linux: update checks, licence activation and other secure connections now work.
- Backblaze: the first index no longer fails when one of your drives has an empty or interrupted Backblaze scan.
- Backblaze: a drive with only a few files is now indexed, instead of being skipped as an interrupted scan.
- A beta version now starts on the Beta update channel, so it's offered the next beta.
- With indexing set to "off" or "interval", background work no longer waits up to a day after a restart, so the Backblaze upload queue and totals stay current.
- Backblaze: the Upload queue no longer shows 0 files when Backblaze's queue isn't available; it shows how many files Backblaze reports are left.
- A Backblaze data folder set in Settings is now used for indexing too.
- The Backblaze Queue no longer empties for a while when Backblaze rewrites its queue file.
- Backblaze Sessions keeps every backup run once KopiaLens has seen it. Backblaze locks each day's log when the day ends, so earlier runs used to disappear.
- The Backblaze dashboard's recently-added folders refresh after each index.
- The Backblaze header chip only warns when a newer file list is waiting to be indexed.
- The Diff column stays neutral when files waiting to upload explain the difference.

## [1.0.1] - 2026-11-04

A small fix release for the tray menu.

### Fixed

- Windows: the tray menu no longer stops responding after KopiaLens has been running for a long time.
- Windows: the tray menu no longer closes by itself while it's open.
- Windows: changing Start at logon from the tray can no longer freeze the tray.
- The notice about snapshots not taken by KopiaLens now reads correctly for a single snapshot.
- Table headers keep the right hover colour in every theme.

### Changed

- The times in the tray menu update every 2 minutes. The tooltip stays live, and changes like pausing or a finished index still show right away.
- The install guide now covers Home Assistant, where your data is kept, and how to uninstall.
- The usage stats page now lists every value KopiaLens sends.

## [1.0.0] - 2026-10-30

KopiaLens 1.0 is the first public release: a backup app for [Kopia](https://github.com/kopia/kopia), with an analysis engine built in. It creates repositories, runs your backups on a schedule and restores files, and it shows you what's inside your backups: the real size of every folder, every version of every file, and what grows each night.

### What it does

- Run backups on a schedule, on your existing repositories or new ones. Kopia is included, and KopiaUI and the kopia command line can keep working alongside it.
- Restore, download or mount anything from any snapshot.
- See where the space goes: every backed-up file and folder with its real physical size after deduplication.
- Find any file in any snapshot, with every version of it.
- Rank snapshots by how much deleting them would free.
- Catch the folders that rewrite themselves on every backup.
- Browse any snapshot like a disk.
- Try a retention policy before you use it, and write exclusions that do what you meant.
- Remove files and folders from existing snapshots, with an optional dry run first (Pro).

### Free and Pro

The whole backup app is free: backups, restore, search and every analysis view, with no time limit and no account. Pro adds the tools that remove junk from inside your old backups: [kopialens.com/pricing](https://kopialens.com/pricing).

### Downloads

Windows (installer and portable zip), macOS (Apple silicon, less tested so far), Linux (AppImage, .deb, .rpm; x64 and arm64), Docker (amd64, arm64) and a Home Assistant add-on. Kopia 0.23.1 is included. Install steps: [kopialens.com/download](https://kopialens.com/download). Checksums are in `SHA256SUMS.txt`.

### Before you install

The Windows and macOS apps aren't code-signed, so Windows shows a SmartScreen warning and macOS blocks the first open. The [download page](https://kopialens.com/download) shows how to get past both.

### Privacy

Nothing in your repository changes unless you start an action. No file names, paths or backup contents leave your computer. A daily update check and anonymous usage stats can each be turned off in **Settings > Updates** ([what is sent](https://kopialens.com/docs/usage-stats)).

❤️ KopiaLens is built on Kopia, and wouldn't exist without it. Thank you to the Kopia team and contributors. KopiaLens is an independent app for Kopia, not affiliated with or endorsed by the Kopia project.
