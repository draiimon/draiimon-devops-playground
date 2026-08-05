#!/bin/bash
# ============================================================
# system_health.sh
# System Health Check Script
# Usage: bash system_health.sh
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SEPARATOR="============================================================"

echo -e "${BLUE}${SEPARATOR}${NC}"
echo -e "${BLUE}         SYSTEM HEALTH REPORT${NC}"
echo -e "${BLUE}${SEPARATOR}${NC}"

# 1. Date and Time
echo -e "\n${YELLOW}[1] DATE & TIME${NC}"
echo "Current date/time: $(date '+%Y-%m-%d %H:%M:%S %Z')"

# 2. System Uptime
echo -e "\n${YELLOW}[2] SYSTEM UPTIME${NC}"
uptime

# 3. CPU Usage
echo -e "\n${YELLOW}[3] CPU USAGE${NC}"
# Get CPU usage % (idle subtracted from 100)
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d '%id,')
CPU_USAGE=$(echo "100 - ${CPU_IDLE}" | bc 2>/dev/null || echo "N/A")
echo "CPU Usage: ${CPU_USAGE}%"
echo ""
echo "Per-core stats:"
grep -E "^cpu[0-9]" /proc/stat | head -8 | awk '{
  total = $2+$3+$4+$5+$6+$7+$8
  idle  = $5
  used  = total - idle
  printf "  %-8s usage: %.1f%%\n", $1, (used/total)*100
}'

# 4. Memory Usage
echo -e "\n${YELLOW}[4] MEMORY USAGE${NC}"
free -h | awk '
  NR==1 { print "  " $0 }
  NR==2 { printf "  %-10s %6s %6s %6s\n", $1, $2, $3, $4 }
'
MEM_USED=$(free | awk 'NR==2{printf "%.1f", $3/$2*100}')
echo "  Memory used: ${MEM_USED}%"

# 5. Top 5 Processes by CPU
echo -e "\n${YELLOW}[5] TOP 5 PROCESSES BY CPU${NC}"
ps aux --sort=-%cpu | awk 'NR<=6 {printf "  %-8s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $11}'

# 6. Disk Space
echo -e "\n${YELLOW}[6] DISK SPACE${NC}"
df -h | awk '
  NR==1 {print "  " $0}
  NR>1  {
    pct = $5+0
    if (pct >= 90) status = "CRITICAL"
    else if (pct >= 75) status = "WARNING "
    else status = "OK      "
    printf "  [%s] %s\n", status, $0
  }
'

# 7. Service Status
echo -e "\n${YELLOW}[7] SERVICE STATUS${NC}"
SERVICES=("docker" "nginx" "ssh" "cron")
for svc in "${SERVICES[@]}"; do
  if systemctl is-active --quiet "$svc" 2>/dev/null; then
    echo -e "  ${GREEN}✔ ${svc} is RUNNING${NC}"
  else
    echo -e "  ${RED}✘ ${svc} is NOT RUNNING${NC}"
  fi
done

# 8. Network Interfaces
echo -e "\n${YELLOW}[8] NETWORK INTERFACES${NC}"
ip -brief addr show 2>/dev/null || ifconfig 2>/dev/null | grep -E "^[a-z]|inet "

# 9. Load Average
echo -e "\n${YELLOW}[9] LOAD AVERAGE${NC}"
LOAD=$(cat /proc/loadavg)
echo "  Load (1m / 5m / 15m): $(echo $LOAD | awk '{print $1, $2, $3}')"
CORES=$(nproc)
echo "  CPU cores: ${CORES}"

echo -e "\n${BLUE}${SEPARATOR}${NC}"
echo -e "${BLUE}         END OF REPORT — $(date '+%H:%M:%S')${NC}"
echo -e "${BLUE}${SEPARATOR}${NC}\n"
