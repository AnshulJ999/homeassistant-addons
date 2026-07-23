<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->
## 2.3.0

- Fixed Spotify re-login being permanently stuck after a refresh token expires or is revoked (Spotify's new 6-month refresh-token expiration policy)
- Fixed the app silently looping instead of prompting re-login when a Spotify refresh token is revoked mid-session
- Added a Spotify connection status/monitor to Settings → Spotify API (live status, Test connection, Disconnect)
