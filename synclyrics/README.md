# SyncLyrics Home Assistant Addon

Real-time synchronized lyrics for your smart home. A feature-rich application that displays synchronized lyrics for your currently playing music, accessible from any device on your network.

Works with Spotify on all platforms. Windows users also get Windows Media integration. Can work on Linux, and also has Docker support.

**Main Repository:** [github.com/AnshulJ999/SyncLyrics](https://github.com/AnshulJ999/SyncLyrics)

---

## ✨ Features

### 🎵 Lyrics
- **5 Providers:** Spotify, LRCLib, Musixmatch, NetEase, QQ Music
- **Word-Sync (Karaoke):** Highlights each word as it's sung
- **Parallel Search:** Queries all providers simultaneously for fastest results
- **Local Caching:** Saves lyrics offline for instant future access
- **Provider Selection:** Manually choose your preferred provider per song
- **Instrumental Detection:** Automatically detects and marks instrumental tracks

### 🎨 Visual Modes
- **Background Styles:** Sharp, Soft, and Blur modes for album art display
- **Visual Mode:** Activates during instrumentals with artist image slideshow
- **Album Art Database:** Caches high-quality art from iTunes, Spotify and Last.fm
- **Artist Images:** Fetches from Deezer, FanArt.tv, TheAudioDB, Spotify

### 🎤 Audio Recognition
- **Shazam-Powered:** Identify any song playing through your browser microphone
- **Frontend Mode:** Uses browser microphone (requires HTTPS)

### 🎛️ Playback Controls
- Play/Pause, Next, Previous track controls
- Like/Unlike tracks (Spotify)
- View playback queue
- Seek bar with progress display

---

## 📥 Installation

1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Click the **⋮** menu (top right) → **Repositories**
3. Add: `https://github.com/AnshulJ999/homeassistant-addons`
4. Find **SyncLyrics** in the addon list and click **Install**
5. Configure the addon (see Configuration section below)
6. Start the addon
7. Access via:
   - **Ingress:** Click "Open Web UI" in the addon page (may not work correctly)
   - **Direct URL:** `http://<YOUR_HA_IP>:9012`

You can also use the mDNS URL: `http://synclyrics.local:9012`

Home assistant's mDNS URL should also work: `http://homeassistant.local:9012`

---

## ⚙️ Configuration

All options are configured through the Home Assistant addon configuration panel.

### Spotify (Required for Spotify integration)

| Option | Description |
|--------|-------------|
| `spotify_client_id` | Your Spotify Developer App Client ID |
| `spotify_client_secret` | Your Spotify Developer App Client Secret |
| `spotify_redirect_uri` | OAuth callback URL (**must match Spotify Dashboard exactly**) |
| `spotify_base_url` | Lyrics API endpoint (default provided) |

### Optional API Keys

| Option | Description |
|--------|-------------|
| `lastfm_api_key` | Last.fm API key for enhanced album art |
| `fanart_tv_api_key` | FanArt.tv API key for high-quality artist images |
| `audiodb_api_key` | TheAudioDB API key (backup for artist images) |

### Server Settings

| Option | Default | Description |
|--------|---------|-------------|
| `server_port` | `9012` | Web UI port |
| `spotify_cache_path` | `/config/.spotify_cache` | Persistent token storage |
| `debug` | `false` | Enable debug logging |
| `log_level` | `INFO` | DEBUG, INFO, WARNING, ERROR, CRITICAL |

### Polling Intervals

| Option | Default | Description |
|--------|---------|-------------|
| `spotify_polling_fast_interval` | `2.0` | Seconds between polls in Spotify-playback mode |
| `spotify_polling_slow_interval` | `6.0` | Seconds between polls in paused mode |

### HTTPS (Required for Browser Microphone)

To use the browser microphone for audio recognition, HTTPS is required.

HTTPS is **enabled by default** for browser microphone access:

- **HTTP:** `http://<YOUR_HA_IP>:9012` (for local use)
- **HTTPS:** `https://<YOUR_HA_IP>:9013` (for mic access on tablets/phones)

The app auto-generates a self-signed certificate. You'll need to accept the browser's security warning on first use.

---

## 🎧 Spotify Developer Setup

To use Spotify features, you need to create a Spotify Developer App:

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Set the **Redirect URI** to match your Home Assistant URL:
   - Example: `https://<YOUR_HA_IP>:9013/callback`

**Important**: HTTPS is required by Spotify for authentication now. The app enables HTTPS by default on port 9013 for this purpose; you'll need to accept the security warning for the self-signed certificates to proceed. 

If you have another method to access HTTPS (such as HASS behind an HTTPS proxy), you can use that directly as well. 

4. Copy the **Client ID** and **Client Secret** to the addon configuration
5. Restart the addon

### Initial Authentication

⚠️ **Important**: For initial OAuth authentication, access the addon **directly via port** (not through Ingress):

```
https://<YOUR_HA_IP>:9013
```

Click the Spotify login link and authorize the application. After successful authentication, you can use either direct access or Ingress.

---

## 🌐 Access Methods

| Method | URL | Best For |
|--------|-----|----------|
| **Direct** | `http://<HA_IP>:9012` | External access, tablets |

### URL Parameters

Append these to the URL for custom displays (e.g., `http://<HA_IP>:9012/?minimal=true`):

| Parameter | Values | Description |
|-----------|--------|-------------|
| `minimal` | `true/false` | Hide all UI except lyrics |
| `sharpAlbumArt` | `true/false` | Sharp album art background |
| `softAlbumArt` | `true/false` | Soft (medium blur) background |
| `artBackground` | `true/false` | Blurred album art background |
| `hideControls` | `true/false` | Hide playback controls |
| `hideProgress` | `true/false` | Hide progress bar |

> **Tip:** These can be configured via the on-screen settings panel, then copy the URL.

---

## 💾 Data Storage

The addon stores data in your Home Assistant `/addon_configs/synclyrics` directory:

- **Lyrics cache:** Saved locally for offline access
- **Album art database:** High-quality art from multiple sources
- **Spotify tokens:** Persistent authentication

### Backup Exclusions

Large database files are **automatically excluded** from Home Assistant backups:
- `album_art_database/`
- `cache/`
- `*.db` files

This prevents backups from becoming excessively large (databases can grow to 1GB+).

---

## 🐛 Troubleshooting

### Spotify Authentication Fails
- Ensure `spotify_redirect_uri` **exactly matches** what's registered in your Spotify Developer Dashboard
- Use your actual Home Assistant URL, not `127.0.0.1` or `localhost`
- Complete initial OAuth via direct port access, not Ingress

### Token Expires After Restart
- Verify `spotify_cache_path` is set to `/config/.spotify_cache`
- The `/config` directory persists across restarts

### Audio Recognition (Browser Mic)
- HTTPS is required for browser microphone access
- Ingress may not work due to SSL requirements
- Use direct HTTPS access if available

### Lyrics Not Showing
- Check that Spotify is playing on a device
- There may be a 2-5 second delay due to API polling
- Check addon logs for errors

### "Spotify not connected" Error
- Ensure you've completed the OAuth flow via direct port access
- Check that your redirect_uri exactly matches the Spotify Dashboard

---

## 🔗 Links

- **Main Repository:** [github.com/AnshulJ999/SyncLyrics](https://github.com/AnshulJ999/SyncLyrics)
- **Report Issues:** [github.com/AnshulJ999/homeassistant-addons/issues](https://github.com/AnshulJ999/homeassistant-addons/issues)

---

## 📜 License

[MIT](https://github.com/AnshulJ999/SyncLyrics/blob/main/LICENSE)
