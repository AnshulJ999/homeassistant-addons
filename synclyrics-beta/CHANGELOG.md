<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->
## 2.3.0-beta

- Fixed Spotify re-login being permanently stuck after a refresh token expires or is revoked (Spotify's new 6-month refresh-token expiration policy)
- Fixed the app silently looping instead of prompting re-login when a Spotify refresh token is revoked mid-session
- Added a Spotify connection status/monitor to Settings → Spotify API (live status, Test connection, Disconnect)

## 2.2.0-beta

- Stability release with several bug fixes since 2.0.5.

## 2.1.1-beta

- Fixed audio recognition in frozen (packaged) builds.

## 2.1.0-beta

- Initial code for local audio fingerprinting support via the SoundFingerprinting library (not yet exposed to general users).
- Bug fixes and better error logging.

## 2.0.5

- Small bug fixes and stability improvements, including some Linux-specific fixes.

## 2.0.0

- Media Browser: embedded Spotify/Music Assistant library browser
- Playback controls: volume slider, device picker, shuffle/repeat
- Full Music Assistant support
- macOS full support (Intel + Apple Silicon)
- Custom font support
- Note: Spotify OAuth scope changes required re-login for this version

## 1.9.0

- Added Music Assistant and Linux support
- UI customization: custom fonts, adjustable lyrics sizing, and more
- Multiple bug fixes and stability improvements

## 1.8.0

- Stable release after 2+ weeks of stability testing

## 1.3.0

- Added the audio recognition engine (Shazam-based track detection)

## 1.0.0

- First release candidate, stable for general use
