#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/log"
FILE_DIR="$LOG_DIR/report.log" 
mkdir -p "$LOG_DIR"
SCAN_PATH="/"

log(){
echo "$(date '+%F %T)|$1"|tee -a "$FILE_DIR"
}

on_error(){
echo "error on line $1 : cmd $2"
exit 1
}

trap ' on_error $LINENO "$BASH_COMMAND" ' ERR

rootcheck(){
if [[ "$EUID" -ne 0 ]]; then
echo "run as sudo"
exit 1
fi
}

usage(){
echo "$0 --path <dir> [--fix] [--summary]"
exit 1
}

FIX_MODE="false"
SUMMARY="false"

while [[ $# -gt 0 ]]; do
case "$1" in
--path)
SCAN_PATH="$2"
shift 2
;;
--fix)
FIX_MODE="true"
shift 1
;;
--summary)
SUMMARY="true"
shift 1
;;
*)
usage
;;

esac 
done

world_writable_files(){
mapfile -t FILES < <(find "$SCAN_PATH" -xdev -type f -perm -0002 2>/dev/null)
echo "${#FILES[@]}"

if $FIX_MODE; then
for file in "${FILES[@]}"; do
chmod o-w "$file"
log "$file -> fixed"
done
fi

}

suid_files(){
mapfile -t FILES < <(find "$SCAN_PATH" -xdev -perm -4000 2>/dev/null)
echo "${#FILES[@]}"
}

sgid_files(){ 
mapfile -t FILES < <(find "$SCAN_PATH" -xdev -perm -2000 2>/dev/null)
echo "${#FILES[@]}"
}
  
sensitive_files(){
for file in /etc/shadow /etc/passwd /etc/sudoers; do
if [[ -f "$file" ]]; then
prem=$(stat -c "%a" "$file")
log  "$file -> $prem"
fi
done
}

rootcheck
if $SUMMARY; then
log "===== Permission Audit Started ====="

WW_COUNT=$(world_writable_files)
SUID_COUNT=$(suid_files)
SGID_COUNT=$(sgid_files)

sensitive_files

log "===== Permission Audit Completed ====="
fi
if $SUMMARY; then
  echo
  echo "📊 SUMMARY"
  echo "World Writable Files: $WW_COUNT"
  echo "SUID Files: $SUID_COUNT"
  echo "SGID Files: $SGID_COUNT"
fi
