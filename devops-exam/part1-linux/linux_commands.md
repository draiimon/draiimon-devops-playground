# Part 1: Linux Basics – Command Documentation

---

## Task 1: File and Directory Management

```bash
# Create the required directory structure
mkdir -p /tmp/devops-exam/{app,logs,config,backup}

# Create an empty log file
touch /tmp/devops-exam/logs/app.log

# Copy a file to another directory
cp /tmp/devops-exam/logs/app.log /tmp/devops-exam/backup/app.log.bak

# Move/rename a file
mv /tmp/devops-exam/backup/app.log.bak /tmp/devops-exam/backup/app_backup.log

# Create a symbolic link
ln -s /tmp/devops-exam/logs/app.log /tmp/devops-exam/app.log.link

# Find all .log files in the directory tree
find /tmp/devops-exam -name "*.log"

# Display sizes in human-readable format
du -sh /tmp/devops-exam/*
```

**What each command does:**
- `mkdir -p` — creates nested directories in one shot; `-p` avoids errors if they exist
- `touch` — creates an empty file or updates timestamp if file exists
- `cp` — copies files; use `-r` for directories
- `mv` — moves or renames files
- `ln -s` — creates a symbolic (soft) link; the link points to the original
- `find` — walks a directory tree searching by name, type, size, date, etc.
- `du -sh` — shows disk usage; `-s` summarizes each argument, `-h` uses human-readable units

---

## Task 2: File Permissions and Ownership

```bash
# Numeric permission: owner=rwx(7), group=r-x(5), others=r-x(5)
chmod 755 /tmp/devops-exam/app

# Symbolic permission: add execute for user
chmod u+x /tmp/devops-exam/app/startup.sh

# Change ownership (requires sudo if not root)
sudo chown devops:developers /tmp/devops-exam/app

# Create a file only the owner can read/write (600)
touch /tmp/devops-exam/config/secrets.env
chmod 600 /tmp/devops-exam/config/secrets.env

# Make a shell script executable
chmod +x part1-linux/system_health.sh

# View current permissions
ls -la /tmp/devops-exam/
```

**Permission bits explained:**
```
-rwxr-xr-x
│├──┤├──┤├──┤
│user group others
│
└─ file type: - = regular file, d = directory, l = link

r = read  (4)
w = write (2)
x = execute (1)

755 = rwxr-xr-x  (owner full, group/others read+execute)
644 = rw-r--r--  (owner read+write, group/others read-only)
600 = rw-------  (owner read+write only — good for secrets)
```

---

## Task 3: Text Processing and Searching

```bash
# Search for the word "ERROR" in a log file
grep "ERROR" /tmp/devops-exam/logs/app.log

# Regex: find lines that START with "ERROR"
grep -E "^ERROR" /tmp/devops-exam/logs/app.log

# Case-insensitive search
grep -i "warning" /tmp/devops-exam/logs/app.log

# Find files by name
find /tmp/devops-exam -name "*.log"

# Find files modified in the last 24 hours
find /tmp/devops-exam -mtime -1

# Find files larger than 1MB
find /tmp -size +1M

# View entire file
cat /tmp/devops-exam/logs/app.log

# View first 20 lines
head -20 /tmp/devops-exam/logs/app.log

# View last 20 lines
tail -20 /tmp/devops-exam/logs/app.log

# Follow a log file in real time (Ctrl+C to stop)
tail -f /tmp/devops-exam/logs/app.log

# Count lines / words / characters
wc -l /tmp/devops-exam/logs/app.log

# Sort lines alphabetically
sort /tmp/devops-exam/logs/app.log

# Show only unique lines
sort /tmp/devops-exam/logs/app.log | uniq

# Count occurrences of each unique line
sort /tmp/devops-exam/logs/app.log | uniq -c | sort -rn
```

---

## Task 4: Process Management

```bash
# List all running processes (snapshot)
ps aux

# Find processes by name
ps aux | grep nginx

# Interactive process viewer (press q to quit)
top

# (If installed) better interactive viewer
htop

# Show CPU, memory, disk in one view
vmstat 1 5

# Kill a process by PID
kill 1234

# Force kill (SIGKILL — use as last resort)
kill -9 1234

# Kill by name
pkill nginx

# Run a process in the background
sleep 60 &

# See background jobs
jobs

# Bring background job to foreground
fg %1

# Check system resource usage
free -h        # memory
df -h          # disk
top -bn1       # CPU snapshot
```

---

## Task 5: Networking Basics

```bash
# Show all network interfaces and IP addresses
ip addr show
# or older style:
ifconfig

# Test connectivity (4 pings)
ping -c 4 google.com

# Show all open ports and listening services
ss -tuln
# or older style:
netstat -tuln

# Check if a specific port is open
nc -zv localhost 8000
# or with curl:
curl -s http://localhost:8000/healthz

# DNS lookup
nslookup google.com
dig google.com

# Download a file
wget https://example.com/file.tar.gz
curl -O https://example.com/file.tar.gz

# Show routing table
ip route
```

---

## Task 6: Package Management (Ubuntu/Debian)

```bash
# Update package index
sudo apt update

# Install a package
sudo apt install -y nginx htop tree

# Remove a package
sudo apt remove nginx

# Remove package + its config files
sudo apt purge nginx

# Search for a package
apt search tree

# List installed packages
dpkg -l
apt list --installed
```

---

## Task 7: System Information

```bash
# Kernel, OS, architecture
uname -a

# Disk usage across all filesystems
df -h

# Disk usage for a specific directory
du -sh /var/log

# Memory usage
free -h

# System uptime and load average
uptime

# View recent system logs
journalctl -n 50

# Follow system logs in real time
journalctl -f

# View a specific service's logs
journalctl -u docker -n 30
```

---

## Task 8: User and Group Management

```bash
# Create a new user
sudo useradd -m -s /bin/bash devops

# Set password for the new user
sudo passwd devops

# Create a group
sudo groupadd developers

# Add user to a group
sudo usermod -aG developers devops

# Switch to another user
su - devops

# Run a command as root
sudo apt update

# Show current user
whoami

# Show user ID, group ID, and group memberships
id devops
```

---

## Task 9: Archiving and Compression

```bash
# Create a tar archive
tar -cvf archive.tar /tmp/devops-exam/app

# Create a compressed .tar.gz archive
tar -czvf archive.tar.gz /tmp/devops-exam/app

# Create a .tar.bz2 archive (better compression, slower)
tar -cjvf archive.tar.bz2 /tmp/devops-exam/app

# Extract .tar.gz
tar -xzvf archive.tar.gz

# Extract .tar.bz2
tar -xjvf archive.tar.bz2

# Extract to specific directory
tar -xzvf archive.tar.gz -C /tmp/restore/

# Compress a single file with gzip
gzip file.txt        # produces file.txt.gz
gunzip file.txt.gz   # restores file.txt

# Zip / Unzip
zip -r archive.zip /tmp/devops-exam/app
unzip archive.zip -d /tmp/restore/
```

**tar flags:**
- `-c` create  `-x` extract  `-z` gzip  `-j` bzip2  `-v` verbose  `-f` filename

---

## Task 10: Shell Scripting Basics

```bash
#!/bin/bash
# --- Variables ---
NAME="DevOps"
VERSION=1

# --- Conditionals ---
if [ "$NAME" = "DevOps" ]; then
  echo "Hello, $NAME!"
else
  echo "Unknown user"
fi

# --- For loop ---
for i in 1 2 3 4 5; do
  echo "Iteration $i"
done

# --- While loop ---
COUNT=0
while [ $COUNT -lt 3 ]; do
  echo "Count: $COUNT"
  COUNT=$((COUNT + 1))
done

# --- Redirect output ---
echo "log entry" >> /tmp/devops-exam/logs/app.log   # append
echo "fresh log" >  /tmp/devops-exam/logs/app.log   # overwrite

# --- Pipes ---
cat /tmp/devops-exam/logs/app.log | grep "ERROR" | wc -l
```

Make a script executable and run it:
```bash
chmod +x myscript.sh
./myscript.sh
# or
bash myscript.sh
```
