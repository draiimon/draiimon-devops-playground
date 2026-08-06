#!/bin/bash
echo "================================"
echo "  SYSTEM HEALTH REPORT"
echo "================================"
echo ""
echo "[1] DATE & TIME"
date
echo ""
echo "[2] UPTIME"
uptime
echo ""
echo "[3] MEMORY USAGE"
free -h
echo ""
echo "[4] DISK SPACE"
df -h
echo ""
echo "[5] TOP 5 PROCESSES BY CPU"
ps aux --sort=-%cpu | head -6
echo ""
echo "[6] CPU INFO"
nproc
cat /proc/loadavg
echo ""
echo "[7] SERVICE STATUS CHECK"
for service in docker nginx; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "  ✔ $service is RUNNING"
    else
        echo "  ✘ $service is NOT running"
    fi
done
echo ""
echo "================================"
echo "  END OF REPORT"
echo "================================"
