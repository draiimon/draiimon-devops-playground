# Part 1: Linux Basics — Formal Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Date Completed:** August 6, 2026  
**Exam:** Junior DevOps Engineer Exam 2026

---

## Environment Overview

All tasks were performed on **WSL2 (Windows Subsystem for Linux 2)** running Ubuntu 24.04 Noble Numbat on a Windows machine. WSL2 provides a full Linux kernel environment inside Windows, making it suitable for all DevOps Linux tasks.

- **Username:** draiimon
- **Hostname:** Aloof
- **Kernel:** Linux 5.15.167.4-microsoft-standard-WSL2
- **Architecture:** x86_64
- **Working Directory:** `~` (home: `/home/draiimon`)

---

## Task 1 — File and Directory Management

### Commands Executed

```bash
# Create required directory structure in one command
mkdir -p /tmp/devops-exam/{app,logs,config,backup}

# Create an empty log file
touch /tmp/devops-exam/logs/app.log

# Copy a file to another directory
cp /tmp/devops-exam/logs/app.log /tmp/devops-exam/config/app.log.bak

# Move/rename the copied file
mv /tmp/devops-exam/config/app.log.bak /tmp/devops-exam/config/app.config

# Create a symbolic link (shortcut) to the log file
ln -s /tmp/devops-exam/logs/app.log /tmp/devops-exam/app/current.log

# Find all .log files in the directory tree
find /tmp/devops-exam -type f -name "*.log"

# Display directory sizes in human-readable format
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
| `mkdir -p` | Creates nested directories in one shot; `-p` avoids error if they already exist; `{}` creates multiple folders at once |
| `touch` | Creates an empty file; if file exists, it updates the timestamp |
| `cp` | Copies a file from source to destination |
| `mv` | Moves or renames a file |
| `ln -s` | Creates a symbolic link (like a shortcut); the link points to the original file |
| `find -name "*.log"` | Searches the directory tree for files matching the pattern |
| `du -sh` | Shows disk usage; `-s` summarizes each item, `-h` shows human-readable sizes (K, M, G) |

📸 **Screenshot:** Task 1 & 2 terminal output (from initial session log)

---

## Task 2 — File Permissions and Ownership

### Commands Executed

```bash
# Numeric permission: 755 = owner(rwx) group(r-x) others(r-x)
chmod 755 /tmp/devops-exam/app/current.log

# Symbolic permission: add execute for the owner (u = user)
chmod u+x /tmp/devops-exam/logs/app.log

# Create a file only the owner can read/write (600 = rw-------)
chmod 600 /tmp/devops-exam/config/app.config

# Make a script executable
chmod +x ~/devops-exam/scripts/system_health.sh

# Verify permissions
ls -l /tmp/devops-exam/logs/app.log
```

### Output

```
-rwxr-xr-x 1 draiimon docker 0 Aug  6 11:47 /tmp/devops-exam/logs/app.log
```

### Explanation

**Permission bits:**
```
- r w x  r - x  r - x
  owner   group  others

r = read    (4)
w = write   (2)
x = execute (1)

755 = rwxr-xr-x  → owner full, group/others read+execute
644 = rw-r--r--  → owner read+write, others read-only
600 = rw-------  → owner only (ideal for secrets/config files)
```

| Command | What it does |
|---------|-------------|
| `chmod 755` | Sets permissions using numeric notation |
| `chmod u+x` | Adds execute permission for the owner (user) only |
| `chmod 600` | Restricts file to owner read/write only — used for sensitive files |
| `ls -l` | Lists files with full permissions, owner, group, size, date |

📸 **Screenshot:** Task 1 & 2 terminal output (from initial session log)

---

## Task 3 — Text Processing and Searching

### Commands Executed

```bash
# Create sample log file with mixed content
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

# Search for ERROR lines
grep "ERROR" /tmp/devops-exam/logs/app.log

# Count ERROR entries
grep -c "ERROR" /tmp/devops-exam/logs/app.log

# Count WARNING entries
grep -c "WARNING" /tmp/devops-exam/logs/app.log

# Regex: find lines starting with "2026"
grep -E "^2026" /tmp/devops-exam/logs/app.log

# View entire file
cat /tmp/devops-exam/logs/app.log

# View first 3 lines
head -3 /tmp/devops-exam/logs/app.log

# View last 3 lines
tail -3 /tmp/devops-exam/logs/app.log

# Count total lines
wc -l /tmp/devops-exam/logs/app.log

# Sort and count unique lines
sort /tmp/devops-exam/logs/app.log | uniq -c | sort -rn
```

### Output

```
ERROR count:   4
WARNING count: 2
Total lines:   10
```

### Explanation

| Command | What it does |
|---------|-------------|
| `grep "pattern"` | Searches for lines containing the pattern |
| `grep -c` | Counts matching lines instead of printing them |
| `grep -E "^2026"` | Uses regex; `^` means "starts with" |
| `cat` | Prints entire file contents |
| `head -n` | Shows first n lines |
| `tail -n` | Shows last n lines |
| `tail -f` | Follows file in real-time (useful for live log monitoring) |
| `wc -l` | Counts lines; `-w` for words, `-c` for characters |
| `sort \| uniq -c` | Sorts lines then counts duplicates — useful for log analysis |

📸 **Screenshot:** {9783574C-26F8-48C6-B020-D4734D1ED9B6}

---

## Task 4 — Process Management

### Commands Executed

```bash
# List all running processes
ps aux

# Find bash processes specifically
ps aux | grep bash

# CPU, memory, process snapshot
top -bn1 | head -15

# Memory usage
free -h

# Disk usage
df -h

# Run process in background
sleep 60 &

# Check background jobs
jobs

# Kill the background job
kill %1

# Verify it's terminated
jobs

# System uptime and load average
uptime
```

### Output (key results)

```
# Background job:
[1] 2959

# Jobs output:
[1]+  Running    sleep 60 &

# After kill:
[1]+  Terminated    sleep 60

# Uptime:
11:59:55 up 21 min,  1 user,  load average: 0.00, 0.05, 0.08
```

### Explanation

| Command | What it does |
|---------|-------------|
| `ps aux` | Shows all running processes with CPU/memory usage |
| `ps aux \| grep name` | Filters processes by name |
| `top -bn1` | One-shot snapshot of system resource usage |
| `free -h` | Shows RAM usage (total/used/free) in human-readable format |
| `sleep 60 &` | Runs sleep command in background; `&` sends it to background |
| `jobs` | Lists background jobs in current shell session |
| `kill %1` | Kills job number 1; use `kill PID` to kill by process ID |
| `uptime` | Shows how long system has been running + load averages (1m/5m/15m) |

📸 **Screenshot:** {17C71811-7978-4AA8-8EFE-2BCA040F5622}

---

## Task 5 — Networking Basics

### Commands Executed

```bash
# Show all network interfaces and IP addresses
ip addr show

# Test connectivity (4 pings)
ping -c 4 google.com

# Show open ports and listening services
ss -tuln

# DNS lookup
nslookup google.com

# Download a file
curl -O https://example.com

# Show routing table
ip route
```

### Output (key results)

```
# Network interfaces found:
lo      - 127.0.0.1 (loopback)
eth0    - 172.25.235.103 (main network)
docker0 - 172.17.0.1 (Docker bridge network)

# Ping result:
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max = 6.44/6.62/6.73 ms

# DNS result:
google.com → 108.177.97.100, 108.177.97.113, 108.177.97.101
```

### Explanation

| Command | What it does |
|---------|-------------|
| `ip addr show` | Shows all network interfaces and their IP addresses |
| `ping -c 4` | Sends 4 ICMP packets to test connectivity; 0% loss = good |
| `ss -tuln` | Shows TCP/UDP listening ports; replaces old `netstat` |
| `nslookup` | Queries DNS to resolve domain names to IP addresses |
| `curl -O` | Downloads a file keeping its original name |
| `ip route` | Shows how network traffic is routed |

📸 **Screenshot:** {647DCCBB-E7E1-4104-89A2-DF8128545D39}

---

## Task 6 — Package Management

### Commands Executed

```bash
# Update package list
sudo apt update

# Install packages (dnsutils for nslookup, tree, net-tools)
sudo apt install -y dnsutils tree net-tools

# Verify nslookup works now
nslookup google.com

# Search for a package
apt search htop

# List installed packages
dpkg -l | head -20

# Remove a package (demo)
sudo apt remove tree

# Install it back
sudo apt install -y tree

# View folder structure with tree
tree /tmp/devops-exam
```

### Output

```
# Tree view of exam folder:
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
| `sudo apt update` | Refreshes the list of available packages from repositories |
| `sudo apt install -y` | Installs packages; `-y` auto-answers yes to prompts |
| `sudo apt remove` | Removes a package but keeps config files |
| `sudo apt purge` | Removes package AND its config files |
| `apt search` | Searches for packages by name or description |
| `dpkg -l` | Lists all installed packages |
| `tree` | Displays directory structure as a visual tree |

📸 **Screenshots:** {8752AA7C-1B95-4172-AD2C-FA3F1C255724} and {683AA4BD-4DAE-4962-8156-98F38FD3B9D7}

---

## Task 7 — System Information

### Commands Executed

```bash
# Kernel and OS information
uname -a

# Disk usage across all filesystems
df -h

# Disk usage of specific directory
du -sh /tmp/devops-exam

# Memory usage
free -h

# System uptime and load
uptime

# View recent system logs
journalctl -n 20
```

### Output (key results)

```
# OS Info:
Linux Aloof 5.15.167.4-microsoft-standard-WSL2 #1 SMP x86_64 GNU/Linux

# Disk usage:
/dev/sdb   1007G   2.2G   954G   1%  /
C:\         465G   391G    74G  85%  /mnt/c

# Exam folder size:
24K    /tmp/devops-exam

# Memory:
Mem:   1.9Gi total   586Mi used   883Mi free
Swap:  0B

# Uptime:
12:18:27 up 39 min, 1 user, load average: 0.00, 0.00, 0.00
```

### Explanation

| Command | What it does |
|---------|-------------|
| `uname -a` | Shows kernel version, machine type, OS name |
| `df -h` | Shows disk space for all mounted filesystems |
| `du -sh` | Shows total size of a specific directory |
| `free -h` | Shows RAM: total, used, free, cache, available |
| `uptime` | How long system is running + load averages (1/5/15 min) |
| `journalctl -n 20` | Shows last 20 lines of system logs |

📸 **Screenshot:** {910C6BBA-044C-4F33-8596-CDB11C01B91D}

---

## Task 8 — User and Group Management

### Commands Executed

```bash
# Create a new user with home directory and bash shell
sudo useradd -m -s /bin/bash devops

# Create a new group
sudo groupadd developers

# Add user to the group
sudo usermod -aG developers devops

# Verify user info
id devops

# Show current user
whoami
id

# List recent entries in passwd file
cat /etc/passwd | tail -5

# List recent entries in group file
cat /etc/group | tail -5
```

### Output

```
# id devops:
uid=1001(devops) gid=1001(devops) groups=1001(devops),1002(developers)

# whoami:
draiimon

# /etc/passwd (last entry):
devops:x:1001:1001::/home/devops:/bin/bash

# /etc/group (last entries):
devops:x:1001:
developers:x:1002:devops
```

### Explanation

| Command | What it does |
|---------|-------------|
| `useradd -m -s /bin/bash` | Creates user; `-m` makes home directory; `-s` sets default shell |
| `groupadd` | Creates a new group |
| `usermod -aG` | Adds user to group; `-a` appends (doesn't replace existing groups); `-G` specifies group |
| `id` | Shows user ID, group ID, and all group memberships |
| `whoami` | Shows current logged-in username |
| `/etc/passwd` | File where all users are stored |
| `/etc/group` | File where all groups and their members are stored |

📸 **Screenshot:** {B548B71D-314E-47D3-8B64-F3F52B088E5F}

---

## Task 9 — Archiving and Compression

### Commands Executed

```bash
# Create a tar archive
tar -cvf /tmp/devops-exam/backup/archive.tar /tmp/devops-exam/app

# Create a compressed .tar.gz archive
tar -czvf /tmp/devops-exam/backup/archive.tar.gz /tmp/devops-exam/logs

# Check sizes
ls -lh /tmp/devops-exam/backup/

# Extract .tar.gz to a different location
mkdir -p /tmp/restore
tar -xzvf /tmp/devops-exam/backup/archive.tar.gz -C /tmp/restore

# Install zip (was not installed)
sudo apt install zip

# Create a zip archive
zip -r /tmp/devops-exam/backup/archive.zip /tmp/devops-exam/config

# Extract zip
unzip /tmp/devops-exam/backup/archive.zip -d /tmp/restore

# Compress single file with gzip
cp /tmp/devops-exam/logs/app.log /tmp/devops-exam/backup/app.log
gzip /tmp/devops-exam/backup/app.log

# Final listing
ls -lh /tmp/devops-exam/backup/
```

### Output

```
total 28K
-rwxr-xr-x 1 draiimon docker 292  Aug 6 12:24 app.log.gz
-rw-r--r-- 1 draiimon docker 10K  Aug 6 12:23 archive.tar
-rw-r--r-- 1 draiimon docker 437  Aug 6 12:23 archive.tar.gz
-rw-r--r-- 1 draiimon docker 390  Aug 6 12:24 archive.zip
```

### Explanation

| Command | What it does |
|---------|-------------|
| `tar -cvf` | Creates a tar archive; `-c` create, `-v` verbose, `-f` filename |
| `tar -czvf` | Creates compressed tar.gz; `-z` adds gzip compression |
| `tar -xzvf` | Extracts tar.gz; `-x` extract |
| `tar -C /path` | Extracts to a specific directory |
| `gzip file` | Compresses a single file, replaces it with `.gz` version |
| `zip -r` | Creates zip archive; `-r` includes subdirectories |
| `unzip -d` | Extracts zip to specified directory |

**tar flags reference:**
- `-c` create | `-x` extract | `-z` gzip | `-j` bzip2 | `-v` verbose | `-f` filename

📸 **Screenshot:** {80B57CD2-FD6A-49E4-9455-D3FAA35F4D0A}

---

## Task 10 — Shell Scripting

### Script 1: system_health.sh

**Location:** `~/devops-exam/scripts/system_health.sh`

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

**Run:**
```bash
chmod +x ~/devops-exam/scripts/system_health.sh
bash ~/devops-exam/scripts/system_health.sh
```

**Output confirmed:**
```
================================
  SYSTEM HEALTH REPORT
================================
[1] DATE & TIME
Thu Aug  6 11:52:56 CST 2026

[2] UPTIME
11:52:56 up 14 min, 1 user, load average: 0.02, 0.23, 0.15

[3] MEMORY USAGE
Mem:   1.9Gi   584Mi   96Mi   3.1Mi   1.4Gi   1.4Gi

[4] DISK SPACE
/dev/sdb  1007G  2.2G  954G  1%  /
C:\        465G  390G   75G  84% /mnt/c

[5] TOP 5 PROCESSES BY CPU
root  1267  0.0  5.0  /usr/bin/dockerd
root  1156  0.1  3.0  /usr/bin/containerd

[6] CPU INFO
4
0.02 0.23 0.15 1/191 2795
================================
```

📸 **Screenshot:** {AEE577C4-8410-42F9-AB54-ED96F4603702}

---

### Script 2: backup.sh

**Location:** `~/devops-exam/scripts/backup.sh`

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

# Remove backups older than 7 days
find "$BACKUP_ROOT" -name "backup_*.tar.gz" -mtime +7 -delete
echo "Old backups cleaned."
ls -lh "$BACKUP_ROOT"
```

**Output confirmed:**
```
Starting backup: 20260806_122657
tar: Removing leading '/' from member names
/tmp/devops-exam/app/
/tmp/devops-exam/app/current.log
Backup saved: /tmp/devops-exam/backup/backup_20260806_122657.tar.gz
Old backups cleaned.

total 28K
-rw-r--r-- 1 draiimon docker 179 Aug  6 12:24 backup_20260806_122657.tar.gz
```

---

### Script 3: log_analysis.sh

**Location:** `~/devops-exam/scripts/log_analysis.sh`

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
File: /tmp/devops-exam/logs/app.log

Total lines: 10
ERROR count: 4
WARNING count: 2

All ERROR lines:
2026-08-06 08:01:05 ERROR Database connection failed
2026-08-06 08:03:15 ERROR Timeout on /api/users after 30s
2026-08-06 08:06:30 ERROR Authentication failed for user: bob
2026-08-06 08:08:40 ERROR Database connection failed

Last 5 entries:
2026-08-06 08:05:25 WARNING Disk usage at 78%
2026-08-06 08:06:30 ERROR Authentication failed for user: bob
2026-08-06 08:07:35 INFO  Health check passed
2026-08-06 08:08:40 ERROR Database connection failed
2026-08-06 08:09:45 INFO  Scheduled job completed
=== END ===
```

📸 **Screenshot:** {882426F5-6777-4AC9-A78B-1F888B793E40}

---

## Summary — Part 1 Completion Status

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

---

## Key Takeaways

- Linux command-line tools are the foundation of DevOps — every server, container, and Kubernetes node runs on Linux
- Shell scripts (`#!/bin/bash`) allow automation of repetitive tasks like backups and health checks
- File permissions (`chmod`, `chown`) are critical for security — sensitive files should always be `600`
- Process management (`ps`, `kill`, `jobs`) is essential for troubleshooting running services
- Package management (`apt`) keeps the system and tools up to date
- Log analysis (`grep`, `tail`, `wc`) is a daily skill for debugging production issues
