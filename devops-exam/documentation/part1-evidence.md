# Part 1 — Linux Basics: Evidence & Progress Tracker

**Candidate:** draiimon  
**Machine:** Aloof (WSL2 — Ubuntu on Windows)  
**Date:** Thu Aug 6, 2026

---

## ✅ Task 1 — File and Directory Management — DONE

Commands executed:
```bash
mkdir -p /tmp/devops-exam/{app,logs,config,backup}
touch /tmp/devops-exam/logs/app.log
cp /tmp/devops-exam/logs/app.log /tmp/devops-exam/config/app.log.bak
mv /tmp/devops-exam/config/app.log.bak /tmp/devops-exam/config/app.config
ln -s /tmp/devops-exam/logs/app.log /tmp/devops-exam/app/current.log
find /tmp/devops-exam -type f -name "*.log"
du -sh /tmp/devops-exam/*
```

Output confirmed:
```
/tmp/devops-exam/logs/app.log

4.0K    /tmp/devops-exam/app
4.0K    /tmp/devops-exam/backup
4.0K    /tmp/devops-exam/config
4.0K    /tmp/devops-exam/logs
```

📸 Screenshot: Task 1 terminal output ✅

---

## ✅ Task 2 — File Permissions and Ownership — DONE

Commands executed:
```bash
chmod 755 /tmp/devops-exam/app/current.log
chmod u+x /tmp/devops-exam/logs/app.log
chmod 600 /tmp/devops-exam/config/app.config
ls -l /tmp/devops-exam/logs/app.log
```

Output confirmed:
```
-rwxr-xr-x 1 draiimon docker 0 Aug  6 11:47 /tmp/devops-exam/logs/app.log
```

📸 Screenshot: Permissions output ✅

---

## ✅ Task 10 — Shell Scripting: system_health.sh — DONE

Script location: `~/devops-exam/scripts/system_health.sh`

Commands executed:
```bash
nano devops-exam/scripts/system_health.sh
chmod +x devops-exam/scripts/system_health.sh
bash devops-exam/scripts/system_health.sh
```

Output confirmed:
```
================================
  SYSTEM HEALTH REPORT
================================

[1] DATE & TIME
Thu Aug  6 11:52:56 CST 2026

[2] UPTIME
 11:52:56 up 14 min,  1 user,  load average: 0.02, 0.23, 0.15

[3] MEMORY USAGE
              total        used        free      shared  buff/cache   available
Mem:           1.9Gi       584Mi        96Mi       3.1Mi       1.4Gi       1.4Gi
Swap:            0B          0B          0B

[4] DISK SPACE
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb        1007G  2.2G  954G   1% /
C:\              465G  390G   75G  84% /mnt/c
D:\               50M   16M   35M  32% /mnt/d
H:\              932G  845G   87G  91% /mnt/h

[5] TOP 5 PROCESSES BY CPU
root          53   0.6   0.7  systemd-journald
root           1   0.2   0.6  /sbin/init
root        1156   0.1   3.0  /usr/bin/containerd
root        1267   0.0   5.0  /usr/bin/dockerd

[6] CPU INFO
4 cores
Load: 0.02 0.23 0.15 1/191 2795
================================
  END OF REPORT
================================
```

📸 Screenshot: {AEE577C4-8410-42F9-AB54-ED96F4603702} ✅

---

## ⏳ Tasks Still To Do

| Task | Status |
|------|--------|
| Task 3 — Text Processing (grep, find, tail, wc) | ⏳ Next |
| Task 4 — Process Management (ps, kill, jobs) | ⏳ |
| Task 5 — Networking (ip addr, ping, ss) | ⏳ |
| Task 6 — Package Management (apt install) | ⏳ |
| Task 7 — System Information (uname, df, free) | ⏳ |
| Task 8 — User Management (useradd, groupadd) | ⏳ |
| Task 9 — Archiving (tar, gzip, zip) | ⏳ |
| Task 10b — backup.sh script | ⏳ |
| Task 10c — log_analysis.sh script | ⏳ |
