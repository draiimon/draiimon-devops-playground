# Part 1: Linux Basics — Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Date Completed:** August 6, 2026  
**Exam:** Junior DevOps Engineer Exam 2026

---

## Environment Overview

All tasks were performed on **WSL2 (Windows Subsystem for Linux 2)** running Ubuntu 24.04 on a Windows machine. WSL2 provides a full Linux kernel environment inside Windows, making it suitable for all DevOps Linux tasks.

- **Username:** draiimon  
- **Hostname:** Aloof  
- **Kernel:** Linux 5.15.167.4-microsoft-standard-WSL2  
- **Architecture:** x86_64  
- **Working Directory:** `~` → `/home/draiimon`

---

## Task 1 — File and Directory Management

### Commands Executed

```bash
mkdir -p /tmp/devops-exam/{app,logs,config,backup}
touch /tmp/devops-exam/logs/app.log
cp /tmp/devops-exam/logs/app.log /tmp/devops-exam/config/app.log.bak
mv /tmp/devops-exam/config/app.log.bak /tmp/devops-exam/config/app.config
ln -s /tmp/devops-exam/logs/app.log /tmp/devops-exam/app/current.log
find /tmp/devops-exam -type f -name "*.log"
du -sh /tmp/devops-exam/*
```

### Output

```
/tmp/devops-exam/logs/app.log

4.0K    /tmp/devops-exam/app
4.0K    /tmp/devops-exam/backup
4.0K    /tmp/devops-exam/config
4.0K    /tmp/devops-exam/logs
```

### Explanation

| Command | What it does |
|---------|-------------|
| `mkdir -p` | Creates nested directories in one shot; `{}` creates multiple at once |
| `touch` | Creates an empty file |
| `cp` | Copies a file from source to destination |
| `mv` | Moves or renames a file |
| `ln -s` | Creates a symbolic link (like a Windows shortcut) |
| `find -name "*.log"` | Searches the folder tree for files matching the pattern |
| `du -sh` | Shows disk usage in human-readable sizes (K, M, G) |

---

## Task 2 — File Permissions and Ownership

### Commands Executed

```bash
chmod 755 /tmp/devops-exam/app/current.log
chmod u+x /tmp/devops-exam/logs/app.log
chmod 600 /tmp/devops-exam/config/app.config
chmod +x ~/devops-exam/scripts/system_health.sh
ls -l /tmp/devops-exam/logs/app.log
```

### Output

```
-rwxr-xr-x 1 draiimon docker 0 Aug  6 11:47 /tmp/devops-exam/logs/app.log
```

### Explanation

```
Permission format:  - r w x  r - x  r - x
                      owner  group  others

r = read (4)   w = write (2)   x = execute (1)

755 = rwxr-xr-x  → owner: full, group/others: read+execute
600 = rw-------  → owner only (used for secrets/config files)
```

| Command | What it does |
|---------|-------------|
| `chmod 755` | Sets permissions using numeric notation |
| `chmod u+x` | Adds execute for the owner only |
| `chmod 600` | Restricts file to owner read/write — ideal for sensitive files |
| `ls -l` | Shows permissions, owner, group, size, date |

### 📸 Screenshot — Tasks 1 & 2

![Task 1 & 2 - Files, Directories and Permissions](screenshots/task01-02-files-permissions.png)

---

## Task 3 — Text Processing and Searching

### Commands Executed

```bash
cat > /tmp/devops-exam/logs/app.log << 'EOF'
2026-08-06 08:00:01 INFO  Server started successfully
2026-08-06 08:01:05 ERROR Database connection failed
2026-08-06 08:02:10 WARNING High memory usage: 85%
2026-08-06 08:03:15 ERROR Timeout on /api/users after 30s
2026-08-06 08:04:20 INFO  Request processed OK
2026-08-06 08:05:25 WARNING Disk usage at 78%
2026-08-06 08:06:30 ERROR Authentication failed for user: bob
2026-08-06 08:07:35 INFO  Health check passed
2026-08-06 08:08:40 ERROR Database connection failed
2026-08-06 08:09:45 INFO  Scheduled job completed
EOF

grep "ERROR" /tmp/devops-exam/logs/app.log
grep -c "ERROR" /tmp/devops-exam/logs/app.log
grep -c "WARNING" /tmp/devops-exam/logs/app.log
grep -E "^2026" /tmp/devops-exam/logs/app.log
cat /tmp/devops-exam/logs/app.log
head -3 /tmp/devops-exam/logs/app.log
tail -3 /tmp/devops-exam/logs/app.log
wc -l /tmp/devops-exam/logs/app.log
sort /tmp/devops-exam/logs/app.log | uniq -c | sort -rn
```

### Results

| Query | Result |
|-------|--------|
| ERROR count | **4** |
| WARNING count | **2** |
| Total lines | **10** |

### Explanation

| Command | What it does |
|---------|-------------|
| `grep "pattern"` | Finds lines containing the pattern |
| `grep -c` | Counts matching lines |
| `grep -E "^2026"` | Regex search; `^` means "starts with" |
| `cat` | Prints entire file |
| `head -3` | Shows first 3 lines |
| `tail -3` | Shows last 3 lines |
| `wc -l` | Counts total lines |
| `sort \| uniq -c` | Sorts then counts duplicates — great for log analysis |

### 📸 Screenshot

![Task 3 - Text Processing](screenshots/task03-text-processing.png)

---

## Task 4 — Process Management

### Commands Executed

```bash
ps aux
ps aux | grep bash
top -bn1 | head -15
free -h
df -h
sleep 60 &
jobs
kill %1
jobs
uptime
```

### Key Output

```
# Background job created:
[1] 2959

# Jobs after running:
[1]+  Running    sleep 60 &

# After kill:
[1]+  Terminated    sleep 60

# Uptime:
11:59:55 up 21 min, 1 user, load average: 0.00, 0.05, 0.08
```

### Explanation

| Command | What it does |
|---------|-------------|
| `ps aux` | Shows all running processes with CPU/memory |
| `ps aux \| grep name` | Filters processes by name |
| `top -bn1` | One-shot resource usage snapshot |
| `free -h` | Shows RAM: total, used, free |
| `sleep 60 &` | Runs a process in the background (`&` = background) |
| `jobs` | Lists current background jobs |
| `kill %1` | Kills job number 1 by job ID |
| `uptime` | System run time + load averages (1m / 5m / 15m) |

### 📸 Screenshot

![Task 4 - Process Management](screenshots/task04-process-management.png)

---

## Task 5 — Networking Basics

### Commands Executed

```bash
ip addr show
ping -c 4 google.com
ss -tuln
nslookup google.com
curl -O https://example.com
ip route
```

### Key Output

```
# Interfaces found:
lo      → 127.0.0.1       (loopback)
eth0    → 172.25.235.103  (main network)
docker0 → 172.17.0.1      (Docker bridge)

# Ping result:
4 packets transmitted, 4 received, 0% packet loss
rtt avg = 6.62 ms

# DNS result:
google.com → 108.177.97.100, 108.177.97.113
```

### Explanation

| Command | What it does |
|---------|-------------|
| `ip addr show` | Shows all network interfaces and IP addresses |
| `ping -c 4` | Sends 4 test packets; 0% loss = good connection |
| `ss -tuln` | Shows open/listening ports (replacement for old `netstat`) |
| `nslookup` | Looks up IP address of a domain via DNS |
| `curl -O` | Downloads a file from the internet |
| `ip route` | Shows how traffic is routed between networks |

### 📸 Screenshot

![Task 5 - Networking](screenshots/task05-networking.png)

---

## Task 6 — Package Management

### Commands Executed

```bash
sudo apt update
sudo apt install -y dnsutils tree net-tools
nslookup google.com
apt search htop
dpkg -l | head -20
sudo apt remove tree
sudo apt install -y tree
tree /tmp/devops-exam
```

### Key Output

```
/tmp/devops-exam
├── app
│   └── current.log -> /tmp/devops-exam/logs/app.log
├── backup
├── config
│   └── app.config
└── logs
    └── app.log

5 directories, 3 files
```

### Explanation

| Command | What it does |
|---------|-------------|
| `sudo apt update` | Refreshes list of available packages |
| `sudo apt install -y` | Installs packages; `-y` skips confirmation |
| `sudo apt remove` | Removes a package |
| `apt search` | Searches for packages by name |
| `dpkg -l` | Lists all installed packages |
| `tree` | Displays folder structure visually with a tree |

### 📸 Screenshots

![Task 6 - Package Management Part 1](screenshots/task06-packages-1.png)

![Task 6 - Package Management Part 2](screenshots/task06-packages-2.png)

---

## Task 7 — System Information

### Commands Executed

```bash
uname -a
df -h
du -sh /tmp/devops-exam
free -h
uptime
journalctl -n 20
```

### Key Output

```
# OS:
Linux Aloof 5.15.167.4-microsoft-standard-WSL2 x86_64 GNU/Linux

# Disk:
/dev/sdb   1007G   2.2G   954G   1%   /
C:\         465G   391G    74G  85%   /mnt/c

# Exam folder:
24K    /tmp/devops-exam

# Memory:
Mem:   1.9Gi   586Mi   883Mi

# Uptime:
12:18:27 up 39 min, load average: 0.00, 0.00, 0.00
```

### Explanation

| Command | What it does |
|---------|-------------|
| `uname -a` | Shows kernel version, machine name, OS |
| `df -h` | Disk usage for all mounted filesystems |
| `du -sh` | Total size of a specific folder |
| `free -h` | RAM usage breakdown |
| `uptime` | How long the system has been running |
| `journalctl -n 20` | Last 20 lines of system logs |

### 📸 Screenshot

![Task 7 - System Information](screenshots/task07-system-info.png)

---

## Task 8 — User and Group Management

### Commands Executed

```bash
sudo useradd -m -s /bin/bash devops
sudo groupadd developers
sudo usermod -aG developers devops
id devops
whoami
id
cat /etc/passwd | tail -5
cat /etc/group | tail -5
```

### Key Output

```
# id devops:
uid=1001(devops) gid=1001(devops) groups=1001(devops),1002(developers)

# /etc/passwd last entry:
devops:x:1001:1001::/home/devops:/bin/bash

# /etc/group last entries:
devops:x:1001:
developers:x:1002:devops
```

### Explanation

| Command | What it does |
|---------|-------------|
| `useradd -m -s /bin/bash` | Creates user with home folder and bash as default shell |
| `groupadd` | Creates a new group |
| `usermod -aG` | Adds user to group without removing existing groups |
| `id` | Shows user ID, group ID, and all memberships |
| `whoami` | Shows current logged-in username |
| `/etc/passwd` | System file storing all user accounts |
| `/etc/group` | System file storing all groups and their members |

### 📸 Screenshot

![Task 8 - User Management](screenshots/task08-user-management.png)

---

## Task 9 — Archiving and Compression

### Commands Executed

```bash
tar -cvf /tmp/devops-exam/backup/archive.tar /tmp/devops-exam/app
tar -czvf /tmp/devops-exam/backup/archive.tar.gz /tmp/devops-exam/logs
ls -lh /tmp/devops-exam/backup/
mkdir -p /tmp/restore
tar -xzvf /tmp/devops-exam/backup/archive.tar.gz -C /tmp/restore
sudo apt install zip
zip -r /tmp/devops-exam/backup/archive.zip /tmp/devops-exam/config
unzip /tmp/devops-exam/backup/archive.zip -d /tmp/restore
cp /tmp/devops-exam/logs/app.log /tmp/devops-exam/backup/app.log
gzip /tmp/devops-exam/backup/app.log
ls -lh /tmp/devops-exam/backup/
```

### Key Output

```
total 28K
-rwxr-xr-x  app.log.gz         292  Aug 6 12:24
-rw-r--r--  archive.tar        10K  Aug 6 12:23
-rw-r--r--  archive.tar.gz     437  Aug 6 12:23
-rw-r--r--  archive.zip        390  Aug 6 12:24
```

### Explanation

| Command | What it does |
|---------|-------------|
| `tar -cvf` | Creates a tar archive (`-c` create, `-v` verbose, `-f` filename) |
| `tar -czvf` | Creates compressed tar.gz (`-z` adds gzip compression) |
| `tar -xzvf` | Extracts a tar.gz archive |
| `tar -C /path` | Extracts to a specific destination folder |
| `gzip` | Compresses a single file into `.gz` format |
| `zip -r` | Creates a zip archive including subfolders |
| `unzip -d` | Extracts zip to a specified folder |

**tar flag cheatsheet:** `-c` create · `-x` extract · `-z` gzip · `-v` verbose · `-f` filename

### 📸 Screenshot

![Task 9 - Archiving](screenshots/task09-archiving.png)

---

## Task 10 — Shell Scripting

### Script 1: system_health.sh

**Purpose:** Displays a full system health report — date, uptime, memory, disk, top processes, and CPU info.

```bash
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
echo "================================"
echo "  END OF REPORT"
echo "================================"
```

**How to run:**
```bash
chmod +x ~/devops-exam/scripts/system_health.sh
bash ~/devops-exam/scripts/system_health.sh
```

### 📸 Screenshot — system_health.sh

![Task 10a - system_health.sh](screenshots/task10a-system-health.png)

---

### Script 2: backup.sh

**Purpose:** Creates a timestamped `.tar.gz` backup and automatically removes backups older than 7 days.

```bash
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
```

**Key concepts used:**
- Variables (`SOURCE`, `TIMESTAMP`) to store reusable values
- `$(date '+%Y%m%d_%H%M%S')` to generate a unique timestamp
- `tar -czvf` for compressed backup
- `find -mtime +7 -delete` for automatic 7-day cleanup

---

### Script 3: log_analysis.sh

**Purpose:** Analyzes a log file — counts total lines, ERRORs, WARNINGs, and shows the most recent entries.

```bash
#!/bin/bash
LOG="/tmp/devops-exam/logs/app.log"

echo "=== LOG ANALYSIS REPORT ==="
echo "File: $LOG"
echo ""
echo "Total lines:"
wc -l < "$LOG"
echo ""
echo "ERROR count:"
grep -c "ERROR" "$LOG"
echo ""
echo "WARNING count:"
grep -c "WARNING" "$LOG"
echo ""
echo "All ERROR lines:"
grep "ERROR" "$LOG"
echo ""
echo "Last 5 entries:"
tail -5 "$LOG"
echo ""
echo "=== END ==="
```

**Output confirmed:**
```
=== LOG ANALYSIS REPORT ===
Total lines:   10
ERROR count:   4
WARNING count: 2

All ERROR lines:
2026-08-06 08:01:05 ERROR Database connection failed
2026-08-06 08:03:15 ERROR Timeout on /api/users after 30s
2026-08-06 08:06:30 ERROR Authentication failed for user: bob
2026-08-06 08:08:40 ERROR Database connection failed

Last 5 entries:
2026-08-06 08:05:25 WARNING Disk usage at 78%
2026-08-06 08:06:30 ERROR  Authentication failed for user: bob
2026-08-06 08:07:35 INFO   Health check passed
2026-08-06 08:08:40 ERROR  Database connection failed
2026-08-06 08:09:45 INFO   Scheduled job completed
=== END ===
```

### 📸 Screenshot — backup.sh + log_analysis.sh

![Task 10bc - Scripts](screenshots/task10bc-scripts.png)

---

## ✅ Part 1 — Completion Summary

| Task | Description | Status |
|------|-------------|--------|
| Task 1 | File and Directory Management | ✅ Complete |
| Task 2 | File Permissions and Ownership | ✅ Complete |
| Task 3 | Text Processing and Searching | ✅ Complete |
| Task 4 | Process Management | ✅ Complete |
| Task 5 | Networking Basics | ✅ Complete |
| Task 6 | Package Management | ✅ Complete |
| Task 7 | System Information | ✅ Complete |
| Task 8 | User and Group Management | ✅ Complete |
| Task 9 | Archiving and Compression | ✅ Complete |
| Task 10a | system_health.sh Script | ✅ Complete |
| Task 10b | backup.sh Script | ✅ Complete |
| Task 10c | log_analysis.sh Script | ✅ Complete |

**All 10 tasks completed. Part 1 — DONE ✅**
