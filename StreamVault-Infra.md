## Storage Architecture

### How Fusion Handles Storage

Fusion uses **local filesystem storage** as its primary storage mechanism:

```
VIDEOS_DIR=/data/videos  <- All VODs, chat, thumbnails stored here
TEMP_DIR=/data/temp      <- Processing workspace (downloads in progress)
```

**Optional CDN support:** The `CDN_URL` environment variable lets you serve files from an external source (S3, CloudFront, Nginx), but Fusion doesn't natively upload to S3 - it only reads/writes to local disk.

---

### Option 2: Local Storage + S3 Sync (Recommended)

```
+------------------+     +--------------+     +------------------+
|     StreamVault       |---->|  Local SSD   |---->|  S3/Backblaze    |
|     Server       |     |  (Hot/Temp)  |     |  (Cold/Archive)  |
+------------------+     +--------------+     +------------------+
                               |                      |
                         Active VODs            All VODs (backup)
                               |                      |
                               +----------+-----------+
                                          |
                                     +----v----+
                                     |   CDN   | <- Set CDN_URL here
                                     +---------+
```

**Implementation:**

1. Fusion downloads to local SSD
2. Use `rclone` or similar to sync completed VODs to S3
3. Set `CDN_URL` to CloudFront/S3 URL for serving
4. Optionally delete old local files after sync

**Sample rclone cron job:**

```bash
# Sync completed VODs to S3 every hour
0 * * * * rclone sync /data/videos s3:bucket-name/videos --min-age 1h
```

**Pros:**
- Fast local downloads (no S3 latency during archiving)
- Cheap long-term storage
- Automatic backup/redundancy

**Cons:**
- More complex setup
- Requires rclone configuration