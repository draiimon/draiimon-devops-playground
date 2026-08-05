#!/bin/bash
# ============================================================
# log_analysis.sh
# Log Analysis Script
# Usage: bash log_analysis.sh [logfile]
# ============================================================

LOG_FILE="${1:-/tmp/devops-exam/logs/app.log}"
SAMPLE_LOG="/tmp/devops-exam/logs/app.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ----- Create sample log if none exists -----
if [ ! -f "$LOG_FILE" ]; then
  echo "Log file not found. Generating sample log at: $SAMPLE_LOG"
  mkdir -p "$(dirname "$SAMPLE_LOG")"
  cat > "$SAMPLE_LOG" <<'EOF'
2026-08-01 08:00:01 INFO  192.168.1.10 - Server started successfully
2026-08-01 08:01:05 INFO  10.0.0.5 - User login: admin
2026-08-01 08:02:10 WARNING 192.168.1.11 - High memory usage: 85%
2026-08-01 08:03:15 ERROR 10.0.0.7 - Database connection failed
2026-08-01 08:04:20 INFO  192.168.1.10 - Request processed in 120ms
2026-08-01 08:05:25 ERROR 10.0.0.8 - Timeout on /api/users after 30s
2026-08-01 08:06:30 WARNING 10.0.0.5 - Disk usage at 78% on /dev/sda1
2026-08-01 08:07:35 ERROR 192.168.1.12 - Authentication failed for user: bob
2026-08-01 08:08:40 INFO  10.0.0.9 - Scheduled job completed: db_backup
2026-08-01 08:09:45 ERROR 10.0.0.7 - Database connection failed
2026-08-01 08:10:50 INFO  192.168.1.10 - Health check passed
2026-08-01 08:11:55 WARNING 10.0.0.6 - Slow query detected: 2500ms
2026-08-01 08:12:00 ERROR 192.168.1.13 - 500 Internal Server Error on /api/orders
2026-08-01 08:13:05 INFO  10.0.0.5 - User logout: admin
2026-08-01 08:14:10 INFO  192.168.1.10 - Config reloaded
EOF
  LOG_FILE="$SAMPLE_LOG"
  echo "Sample log created."
fi

echo -e "\n${BLUE}============================================================${NC}"
echo -e "${BLUE}  LOG ANALYSIS REPORT: ${LOG_FILE}${NC}"
echo -e "${BLUE}============================================================${NC}"

# 1. Total lines
TOTAL=$(wc -l < "$LOG_FILE")
echo -e "\n${YELLOW}[1] TOTAL LOG ENTRIES:${NC} $TOTAL"

# 2. Count by level
echo -e "\n${YELLOW}[2] COUNT BY LOG LEVEL:${NC}"
for level in ERROR WARNING INFO DEBUG; do
  count=$(grep -c " $level " "$LOG_FILE" 2>/dev/null || echo 0)
  printf "  %-10s %d\n" "$level" "$count"
done

# 3. All ERROR lines
echo -e "\n${YELLOW}[3] ERROR LINES:${NC}"
grep " ERROR " "$LOG_FILE" | sed 's/^/  /'

# 4. Lines starting with a year (regex)
echo -e "\n${YELLOW}[4] ENTRIES MATCHING DATE PATTERN (^2026):${NC}"
grep -E "^2026" "$LOG_FILE" | wc -l | awk '{print "  Found: " $1 " entries"}'

# 5. 10 most recent entries
echo -e "\n${YELLOW}[5] 10 MOST RECENT LOG ENTRIES:${NC}"
tail -10 "$LOG_FILE" | sed 's/^/  /'

# 6. Unique IP addresses
echo -e "\n${YELLOW}[6] UNIQUE IP ADDRESSES FOUND:${NC}"
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "$LOG_FILE" | sort | uniq -c | sort -rn | \
  awk '{printf "  %-20s (seen %d time(s))\n", $2, $1}'

# 7. Most common log messages (deduped)
echo -e "\n${YELLOW}[7] MOST REPEATED MESSAGES:${NC}"
awk '{for(i=4;i<=NF;i++) printf $i" "; print ""}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5 | \
  sed 's/^/  /'

# 8. Warnings
echo -e "\n${YELLOW}[8] WARNING LINES:${NC}"
grep " WARNING " "$LOG_FILE" | sed 's/^/  /'

echo -e "\n${GREEN}Analysis complete.${NC}\n"
