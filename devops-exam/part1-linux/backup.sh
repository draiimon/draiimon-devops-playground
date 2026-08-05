#!/bin/bash
# ============================================================
# backup.sh
# Automated Timestamped Backup Script
# Usage: bash backup.sh [source_dir]
# ============================================================

# ----- Configuration -----
SOURCE_DIR="${1:-/tmp/devops-exam/app}"   # Default source, override via arg
BACKUP_ROOT="/tmp/devops-exam/backup"
RETENTION_DAYS=7
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="${BACKUP_ROOT}/backup_${TIMESTAMP}"
ARCHIVE_NAME="${BACKUP_ROOT}/backup_${TIMESTAMP}.tar.gz"
LOG_FILE="${BACKUP_ROOT}/backup.log"

# ----- Colors -----
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ----- Setup -----
mkdir -p "$BACKUP_ROOT"
log "${YELLOW}=== Backup started: ${TIMESTAMP} ===${NC}"

# ----- Validate Source -----
if [ ! -d "$SOURCE_DIR" ]; then
  log "${RED}ERROR: Source directory '$SOURCE_DIR' does not exist.${NC}"
  exit 1
fi

log "Source: $SOURCE_DIR"
log "Backup dir: $BACKUP_DIR"
log "Archive: $ARCHIVE_NAME"

# ----- Copy Files -----
log "Copying files..."
mkdir -p "$BACKUP_DIR"
cp -r "$SOURCE_DIR/." "$BACKUP_DIR/" 2>/dev/null

if [ $? -ne 0 ]; then
  log "${RED}ERROR: File copy failed.${NC}"
  exit 1
fi

FILE_COUNT=$(find "$BACKUP_DIR" -type f | wc -l)
log "${GREEN}Copied ${FILE_COUNT} file(s) to backup directory.${NC}"

# ----- Compress Backup -----
log "Compressing backup..."
tar -czf "$ARCHIVE_NAME" -C "$BACKUP_ROOT" "backup_${TIMESTAMP}" 2>/dev/null

if [ $? -ne 0 ]; then
  log "${RED}ERROR: Compression failed.${NC}"
  exit 1
fi

ARCHIVE_SIZE=$(du -sh "$ARCHIVE_NAME" | cut -f1)
log "${GREEN}Archive created: ${ARCHIVE_NAME} (${ARCHIVE_SIZE})${NC}"

# ----- Remove Uncompressed Backup Dir -----
rm -rf "$BACKUP_DIR"
log "Cleaned up temporary backup directory."

# ----- Remove Old Backups -----
log "Checking for backups older than ${RETENTION_DAYS} days..."
OLD_COUNT=$(find "$BACKUP_ROOT" -name "backup_*.tar.gz" -mtime +"$RETENTION_DAYS" | wc -l)

if [ "$OLD_COUNT" -gt 0 ]; then
  find "$BACKUP_ROOT" -name "backup_*.tar.gz" -mtime +"$RETENTION_DAYS" -exec rm -f {} \;
  log "${YELLOW}Removed ${OLD_COUNT} old backup(s).${NC}"
else
  log "No old backups to remove."
fi

# ----- Summary -----
REMAINING=$(find "$BACKUP_ROOT" -name "backup_*.tar.gz" | wc -l)
log "${GREEN}=== Backup completed successfully ===${NC}"
log "Total backups retained: ${REMAINING}"
log "Log file: ${LOG_FILE}"
