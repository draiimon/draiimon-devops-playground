#!/bin/bash
SOURCE="/tmp/devops-exam/app"
BACKUP_ROOT="/tmp/devops-exam/backup"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
ARCHIVE="${BACKUP_ROOT}/backup_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_ROOT"
echo "Starting backup: $TIMESTAMP"
tar -czvf "$ARCHIVE" "$SOURCE"
echo "Backup saved: $ARCHIVE"

find "$BACKUP_ROOT" -name "backup_*.tar.gz" -mtime +7 -delete
echo "Old backups cleaned."
ls -lh "$BACKUP_ROOT"
