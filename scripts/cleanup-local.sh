#!/bin/bash
# StreamVault Local Cleanup Script
# Deletes local files older than X days that have been successfully synced to B2
# Runs daily via cron
set -e

# Configuration - adjust these for your setup
VIDEOS_DIR="${VIDEOS_DIR:-/data/videos}"
B2_BUCKET="${B2_BUCKET:-backblaze:streamvault-vods}"
LOG_DIR="${LOG_DIR:-/var/log/streamvault}"
DAYS_OLD="${DAYS_OLD:-7}"  # Delete files older than this many days
DRY_RUN="${DRY_RUN:-false}"  # Set to "true" to preview without deleting

# Ensure log directory exists
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cleanup.log"

echo "[$(date)] ========================================" >> "$LOG_FILE"
echo "[$(date)] Starting cleanup of files older than $DAYS_OLD days..." >> "$LOG_FILE"
echo "[$(date)] Videos dir: $VIDEOS_DIR" >> "$LOG_FILE"
echo "[$(date)] B2 bucket: $B2_BUCKET" >> "$LOG_FILE"
if [ "$DRY_RUN" = "true" ]; then
    echo "[$(date)] DRY RUN MODE - no files will be deleted" >> "$LOG_FILE"
fi

deleted_count=0
skipped_count=0
error_count=0

# Find files older than DAYS_OLD days
while IFS= read -r -d '' file; do
    # Get relative path from VIDEOS_DIR
    rel_path="${file#$VIDEOS_DIR/}"

    # Check if file exists in B2
    if rclone lsf "$B2_BUCKET/$rel_path" &>/dev/null; then
        if [ "$DRY_RUN" = "true" ]; then
            echo "[$(date)] [DRY RUN] Would delete: $file" >> "$LOG_FILE"
        else
            echo "[$(date)] Deleting synced file: $file" >> "$LOG_FILE"
            if rm -f "$file"; then
                ((deleted_count++))
            else
                echo "[$(date)] ERROR: Failed to delete: $file" >> "$LOG_FILE"
                ((error_count++))
            fi
        fi
    else
        echo "[$(date)] Skipping (not in B2): $rel_path" >> "$LOG_FILE"
        ((skipped_count++))
    fi
done < <(find "$VIDEOS_DIR" -type f -mtime +"$DAYS_OLD" -print0 2>/dev/null)

# Remove empty directories
if [ "$DRY_RUN" != "true" ]; then
    empty_dirs=$(find "$VIDEOS_DIR" -type d -empty 2>/dev/null | wc -l)
    find "$VIDEOS_DIR" -type d -empty -delete 2>/dev/null || true
    echo "[$(date)] Removed $empty_dirs empty directories" >> "$LOG_FILE"
fi

echo "[$(date)] Cleanup complete:" >> "$LOG_FILE"
echo "[$(date)]   Deleted: $deleted_count files" >> "$LOG_FILE"
echo "[$(date)]   Skipped: $skipped_count files (not in B2)" >> "$LOG_FILE"
echo "[$(date)]   Errors: $error_count files" >> "$LOG_FILE"
echo "[$(date)] ========================================" >> "$LOG_FILE"

# Exit with error if any deletions failed
if [ $error_count -gt 0 ]; then
    exit 1
fi

exit 0
