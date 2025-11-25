# SyncLyrics Home Assistant Add-on

## Configuration

| Option | Description |
|--------|-------------|
| `spotify_client_id` | Your Spotify Developer App Client ID |
| `spotify_client_secret` | Your Spotify Developer App Client Secret |
| `spotify_redirect_uri` | OAuth callback URL (must match Spotify Dashboard) |
| `spotify_base_url` | Lyrics API endpoint |
| `server_port` | Port for the web interface (default: 9012) |
| `spotify_cache_path` | Path for persistent Spotify token storage |

## Initial Setup

### 1. Create Spotify Developer App

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Set the Redirect URI to match your Home Assistant setup:
   - For direct access: `http://<YOUR_HA_IP>:9012/callback`
   - Example: `http://192.168.1.100:9012/callback`
4. Copy the Client ID and Client Secret

### 2. Configure the Add-on

1. Enter your `spotify_client_id` and `spotify_client_secret`
2. Set `spotify_redirect_uri` to **exactly match** what you entered in Spotify Dashboard
3. Start the add-on

### 3. Authenticate with Spotify

⚠️ **Important**: For initial OAuth authentication, access the add-on directly via port (not through ingress):

```
http://<YOUR_HA_IP>:9012
```

Click the Spotify login link and authorize the application. After successful authentication, you can use either direct access or ingress.

## Ingress vs Direct Access

| Access Method | URL | Best For |
|---------------|-----|----------|
| Direct | `http://<HA_IP>:9012` | Initial OAuth, external access |
| Ingress | Via HA sidebar | Internal use after OAuth |

## Troubleshooting

### "Spotify not connected" error
- Ensure you've completed the OAuth flow via direct port access
- Check that your redirect_uri exactly matches the Spotify Dashboard

### Token expires after restart
- Verify `spotify_cache_path` is set to a persistent location like `/config/.spotify_cache`
- The `/config` directory is mapped to Home Assistant's config folder for persistence

