# 🔐 Linux Permission Audit Script

## 📌 Overview

This is a Bash-based Linux Permission Audit tool that scans a given directory (or the entire system) for potentially insecure file permissions. It checks for:

- World-writable files
- SUID files
- SGID files
- Permissions of sensitive system files (`/etc/shadow`, `/etc/passwd`, `/etc/sudoers`)

It can also optionally fix world-writable files by removing the "others write" permission.

---

## 🎯 Purpose

This script was built to understand:

- How Linux file permissions work
- The meaning of read (r), write (w), execute (x)
- Special permission bits (SUID, SGID)
- How world-writable files can be a security risk
- How to safely scan systems using `find`
- Proper Bash scripting practices (error handling, traps, arrays, functions)

---

## 🧠 What I Learned

While building this script, I learned how Linux permissions are structured (owner, group, others) and how numeric permissions like `755`, `644`, and special bits `4000` (SUID) and `2000` (SGID) work. I learned how dangerous world-writable files (`-perm -0002`) can be because any user can modify them. I also learned how to use the `find` command properly with permission filters, how to safely store results in arrays using `mapfile`, how to implement error handling with `set -Eeuo pipefail`, and how to use traps to catch script errors. Additionally, I understood the importance of running security scans as root when auditing system-level files.

---

## ⚙️ Requirements

- Linux system
- Bash shell
- Root privileges (required for full system scan)

---

## 🚀 How to Run

### 1️⃣ Make the script executable

```bash
chmod +x audit.sh
```

### 2️⃣ Run with root privileges

Scan entire system with summary:

```bash
sudo ./audit.sh --summary
```

Scan a specific directory:

```bash
sudo ./audit.sh --path /home --summary
```

Scan and automatically fix world-writable files:

```bash
sudo ./audit.sh --path /home --fix --summary
```

---

## 📊 Available Options

| Option       | Description |
|--------------|------------|
| `--path`     | Directory to scan (default is `/`) |
| `--fix`      | Remove world write permission from files |
| `--summary`  | Display a summary after scan |

---

## 📝 Log Output

All scan results are saved inside:

```
log/report.log
```

This file contains:
- Permission audit start and end timestamps
- Sensitive file permissions
- Any fixed files (if `--fix` is used)

---

## ⚠️ Warning

Running with `--fix` will modify file permissions. Always review results before running in production environments.

---

## 🔮 Future Improvements

- Export report as CSV
- Add email notifications
- Add colored terminal output
- Add parallel scanning for performance
- Convert into a full security auditing toolkit

---

## 👨‍💻 Author

Built as a learning project to strengthen Linux, Bash scripting, and system security fundamentals.
