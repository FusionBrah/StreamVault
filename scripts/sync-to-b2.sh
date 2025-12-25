#!/bin/bash
# StreamVault -> Backblaze B2 Sync Script
# Runs hourly via cron to sync completed VODs to B2 storage
set -e

# Configuration - adjust these for your setup
VIDEOS_DIR="${VIDEOS_DIR:-/data/videos}"
B2_BUCKET="${B2_BUCKET:-backblaze:streamvault-vods}"
LOG_DIR="${LOG_DIR:-/var/log/streamvault}"
LOCK_FILE="/tmp/b2-sync.lock"
MIN_AGE="${MIN_AGE:-1h}"  # Don't sync files younger than this (avoids in-progress downloads)

# Ensure log directory exists
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/b2-sync.log"

# Prevent concurrent runs
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "[$(date)] Sync already running, exiting" >> "$LOG_FILE"
    exit 1
fi

echo "[$(date)] Starting B2 sync..." >> "$LOG_FILE"
echo "[$(date)] Source: $VIDEOS_DIR -> Destination: $B2_BUCKET" >> "$LOG_FILE"

# Sync completed files to B2
# --min-age: Skip files still being written
# --transfers: Number of file transfers in parallel
# --checkers: Number of checkers to run in parallel
# --exclude: Skip temporary/partial files
rclone sync "$VIDEOS_DIR" "$B2_BUCKET" \
    --min-age "$MIN_AGE" \
    --transfers 4 \
    --checkers 8 \
    --log-file "$LOG_FILE" \
    --log-level INFO \
    --stats 1m \
    --exclude "*.tmp" \
    --exclude "*.part" \
    --exclude ".DS_Store" \
    --exclude "*.log"

SYNC_EXIT=$?

if [ $SYNC_EXIT -eq 0 ]; then
    echo "[$(date)] Sync completed successfully" >> "$LOG_FILE"
else
    echo "[$(date)] Sync failed with exit code $SYNC_EXIT" >> "$LOG_FILE"
fi

exit $SYNC_EXIT
