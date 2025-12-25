# StreamVault Infrastructure Scripts

Scripts for syncing StreamVault video storage to Backblaze B2 with Cloudflare CDN.

## Architecture

```
StreamVault Server          Backblaze B2              Cloudflare CDN
+----------------+          +------------------+      +-------------+
| /data/videos/  |  rclone  | streamvault-vods |      |             |
|   channel1/    | -------> |   channel1/      | <--- | cdn.domain  |
|   channel2/    |  hourly  |   channel2/      |      |             |
+----------------+          +------------------+      +-------------+
        |                                                    |
        | cleanup after 7 days                               |
        +----------------------------------------------------+
                         Users stream from CDN
```

## Setup

### 1. Backblaze B2

1. Create a B2 bucket:
   - Name: `streamvault-vods`
   - File visibility: **Public**
   - Encryption: None
   - Object Lock: Disabled

2. Create an Application Key:
   - Restrict to bucket: `streamvault-vods`
   - Save the `keyID` and `applicationKey`

### 2. Cloudflare (Free Egress)

Cloudflare is a Backblaze Bandwidth Alliance partner = **free egress**.

1. Add DNS record:
   ```
   Type: CNAME
   Name: cdn (or your subdomain)
   Target: f000.backblazeb2.com (check your B2 bucket for exact endpoint)
   Proxy: Enabled (orange cloud)
   ```

2. SSL/TLS settings:
   - Mode: Full (strict)

3. Optional - Cache rules for video files:
   - Cache everything
   - Edge TTL: 1 month

4. B2 Bucket CORS (if needed for video playback):
   ```json
   [
     {
       "corsRuleName": "allowAll",
       "allowedOrigins": ["*"],
       "allowedHeaders": ["*"],
       "allowedOperations": ["s3_get", "s3_head"],
       "exposeHeaders": ["Content-Length", "Content-Type"],
       "maxAgeSeconds": 3600
     }
   ]
   ```

### 3. Install rclone

```bash
# Linux
curl https://rclone.org/install.sh | sudo bash

# macOS
brew install rclone

# Verify
rclone version
```

### 4. Configure rclone

```bash
rclone config
```

Follow prompts:
```
n) New remote
name> backblaze
Storage> b2
account> YOUR_KEY_ID
key> YOUR_APPLICATION_KEY
hard_delete> true
(leave other options as default)
```

Test connection:
```bash
rclone lsd backblaze:streamvault-vods
```

### 5. Install Scripts

```bash
# Create directory
sudo mkdir -p /opt/streamvault/scripts
sudo mkdir -p /var/log/streamvault

# Copy scripts
sudo cp sync-to-b2.sh cleanup-local.sh /opt/streamvault/scripts/
sudo chmod +x /opt/streamvault/scripts/*.sh

# Test sync (dry run first)
rclone sync /data/videos backblaze:streamvault-vods --dry-run

# Test cleanup (dry run)
DRY_RUN=true /opt/streamvault/scripts/cleanup-local.sh
```

### 6. Configure Cron

```bash
# Edit crontab
crontab -e

# Add these lines:
# Sync to B2 every hour
0 * * * * /opt/streamvault/scripts/sync-to-b2.sh

# Cleanup local files older than 7 days (daily at 3am)
0 3 * * * /opt/streamvault/scripts/cleanup-local.sh
```

### 7. Configure StreamVault

Set `CDN_URL` in docker-compose.yml:

```yaml
environment:
  - CDN_URL=https://cdn.yourdomain.com/file/streamvault-vods
```

URL format:
- Direct B2: `https://f000.backblazeb2.com/file/streamvault-vods`
- Cloudflare: `https://cdn.yourdomain.com/file/streamvault-vods`

Restart StreamVault:
```bash
docker compose up -d
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VIDEOS_DIR` | `/data/videos` | Local video storage path |
| `B2_BUCKET` | `backblaze:streamvault-vods` | rclone remote:bucket |
| `LOG_DIR` | `/var/log/streamvault` | Log file directory |
| `MIN_AGE` | `1h` | Don't sync files younger than this |
| `DAYS_OLD` | `7` | Delete local files older than this |
| `DRY_RUN` | `false` | Preview cleanup without deleting |

## Logs

- Sync log: `/var/log/streamvault/b2-sync.log`
- Cleanup log: `/var/log/streamvault/cleanup.log`

## Manual Operations

```bash
# Force sync now
/opt/streamvault/scripts/sync-to-b2.sh

# Preview cleanup (no deletions)
DRY_RUN=true /opt/streamvault/scripts/cleanup-local.sh

# Cleanup with different retention
DAYS_OLD=14 /opt/streamvault/scripts/cleanup-local.sh

# Check what's in B2
rclone ls backblaze:streamvault-vods

# Check sync status
rclone check /data/videos backblaze:streamvault-vods
```

## Troubleshooting

**Sync not running:**
```bash
# Check if lock file exists
ls -la /tmp/b2-sync.lock

# Check cron logs
grep CRON /var/log/syslog
```

**Files not deleting:**
```bash
# Check if file exists in B2
rclone lsf backblaze:streamvault-vods/channel/folder/file.mp4

# Run cleanup with debug
DRY_RUN=true /opt/streamvault/scripts/cleanup-local.sh
cat /var/log/streamvault/cleanup.log
```

**CDN not serving files:**
- Verify `CDN_URL` format matches your B2 bucket path
- Check Cloudflare DNS is proxied (orange cloud)
- Test direct B2 URL first
