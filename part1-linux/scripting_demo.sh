#!/bin/bash
# ============================================================
# scripting_demo.sh
# Demonstrates: variables, if/else, for loop, while loop,
#               output redirection (> and >>), pipes
# ============================================================

LOG_FILE="/tmp/devops-exam/logs/script_output.log"
mkdir -p /tmp/devops-exam/logs

# --- Variables ---
CANDIDATE="draiimon"
EXAM="Junior DevOps Engineer Exam 2026"

echo "Candidate: $CANDIDATE"
echo "Exam: $EXAM"

# --- Redirect output to file (>) ---
echo "Script started at: $(date)" > "$LOG_FILE"
echo "Candidate: $CANDIDATE" >> "$LOG_FILE"

# --- if/else conditional ---
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

echo ""
echo "[DISK CHECK]"
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "  WARNING: Disk usage is at ${DISK_USAGE}% — getting full!"
    echo "WARNING: Disk at ${DISK_USAGE}%" >> "$LOG_FILE"
else
    echo "  OK: Disk usage is at ${DISK_USAGE}% — healthy."
    echo "OK: Disk at ${DISK_USAGE}%" >> "$LOG_FILE"
fi

# --- for loop ---
echo ""
echo "[FOR LOOP — Checking directories]"
for dir in app logs config backup; do
    if [ -d "/tmp/devops-exam/$dir" ]; then
        echo "  ✔ /tmp/devops-exam/$dir exists"
    else
        echo "  ✘ /tmp/devops-exam/$dir is missing"
    fi
done

# --- while loop ---
echo ""
echo "[WHILE LOOP — Countdown]"
COUNT=3
while [ $COUNT -gt 0 ]; do
    echo "  Countdown: $COUNT"
    COUNT=$((COUNT - 1))
done
echo "  Done!"

# --- Pipes ---
echo ""
echo "[PIPES — Top 3 largest files in /tmp]"
find /tmp -type f 2>/dev/null | xargs ls -lh 2>/dev/null | sort -k5 -rh | head -3

# --- Append final status to log ---
echo "Script completed at: $(date)" >> "$LOG_FILE"
echo ""
echo "Log written to: $LOG_FILE"
cat "$LOG_FILE"
