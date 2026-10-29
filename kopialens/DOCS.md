# KopiaLens

KopiaLens shows what your Kopia backups hold, what takes the space, and lets you clean them up.

## Opening it

Open **KopiaLens** in the sidebar. Home Assistant signs you in, and only admins see it.

To open KopiaLens from another device without Home Assistant, enter a port under **Network** in the add-on's Configuration tab. That address asks for KopiaLens's own sign-in if you set one up in KopiaLens. Without it, anyone who can reach the port can open KopiaLens.

## Your repositories

KopiaLens can reach these Home Assistant folders:

| Folder | Access |
|---|---|
| `/share` | read and write |
| `/media` | read and write |
| `/backup` | read and write |
| `/homeassistant` | read only |

A repository on a NAS works when the share is added under **Settings > System > Storage** in Home Assistant: it then appears under `/share`, `/media` or `/backup`. Cloud repositories (S3, B2, SFTP and others) need no folder.

## Options

- **Computer name for backups** and **User name for backups**: kopia names every snapshot `user@computer`. Snapshots made here use these names, so they keep one history even when the add-on is reinstalled.
- **Snapshot mounting**: lets KopiaLens open a snapshot as a folder. It needs extra permissions, which is why Home Assistant shows a lower security rating for this add-on. Off by default.

## Home Assistant backups

Home Assistant backups include KopiaLens's settings and repository connections, but not its index: it can be large, and KopiaLens rebuilds it from your repositories after a restore.
