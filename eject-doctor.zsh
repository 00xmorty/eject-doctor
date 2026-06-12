#!/usr/bin/env zsh
# eject-doctor
# Read-only macOS external volume eject diagnostics. No sudo, no kill, no unmount.

set -u

VERSION="0.1.0"
MAX_PROCESSES=20

usage() {
  cat <<'EOF'
eject-doctor

Usage:
  ./eject-doctor.zsh list
  ./eject-doctor.zsh doctor /Volumes/MyDisk
  ./eject-doctor.zsh sample
  ./eject-doctor.zsh help
  ./eject-doctor.zsh --version

Safety:
  - Read-only v0.1.0.
  - No sudo, no kill, no unmount, no force eject.
  - Explains likely blockers so you can close apps or use Finder/Disk Utility yourself.
EOF
}

has_cmd() { command -v "$1" >/dev/null 2>&1 }

say_warn() { print -r -- "warning: $*" >&2 }

volume_name() {
  local p="$1"
  basename "$p"
}

print_volume_list() {
  echo "Mounted external-style volumes:"
  local found=0
  if [[ -d /Volumes ]]; then
    for v in /Volumes/*(N); do
      [[ -d "$v" ]] || continue
      found=1
      local name fs used avail cap
      name="$(volume_name "$v")"
      fs="$(df -H "$v" 2>/dev/null | awk 'NR==2 {print $1}')"
      used="$(df -H "$v" 2>/dev/null | awk 'NR==2 {print $3}')"
      avail="$(df -H "$v" 2>/dev/null | awk 'NR==2 {print $4}')"
      cap="$(df -H "$v" 2>/dev/null | awk 'NR==2 {print $5}')"
      printf "  %-28s used=%-7s avail=%-7s cap=%-5s fs=%s\n" "$name" "${used:-?}" "${avail:-?}" "${cap:-?}" "${fs:-?}"
    done
  fi
  if [[ "$found" == "0" ]]; then
    echo "  none found under /Volumes"
  fi
}

print_diskutil_info() {
  local target="$1"
  echo "Disk info:"
  if has_cmd diskutil; then
    diskutil info "$target" 2>/dev/null | awk '
      /Device Identifier|Volume Name|Mounted|Mount Point|File System Personality|Protocol|Read-Only Volume|Ejectable|Removable Media|Device Location/ {print "  " $0}
    '
  else
    echo "  diskutil not found"
  fi
}

print_processes() {
  local target="$1"
  local prefix="$target/"
  echo "Likely open files/processes touching this volume:"
  if ! has_cmd lsof; then
    echo "  lsof not found"
    return 0
  fi
  # Read-only lsof scan. We intentionally avoid lsof +D because recursive directory walks can be slow.
  local rows
  rows="$(lsof -nP 2>/dev/null | awk -v p="$prefix" -v exact="$target" '
    NR == 1 {next}
    index($0, p) > 0 || $NF == exact {print $1 "\t" $2 "\t" $3 "\t" $NF}
  ' | sort -u | head -n "$MAX_PROCESSES")"
  if [[ -z "$rows" ]]; then
    echo "  none visible to current user"
    echo "  note: processes owned by other users may require Activity Monitor or Disk Utility to inspect."
    return 0
  fi
  printf "  %-22s %-8s %-12s %s\n" "COMMAND" "PID" "USER" "PATH"
  print -r -- "$rows" | while IFS=$'\t' read -r cmd pid user path; do
    printf "  %-22s %-8s %-12s %s\n" "$cmd" "$pid" "$user" "$path"
  done
}

print_known_culprits() {
  cat <<'EOF'
Common macOS eject blockers to check manually:
  - Finder window open inside the volume
  - Spotlight indexing (mds, mdworker, mds_stores)
  - backup/migration tools (backupd, systemmigrationd)
  - menu bar/system monitors (iStat, MenuBar Stats, antivirus scanners)
  - media/indexing apps previewing files from the disk

Safe next steps:
  1. Close Finder tabs/windows showing the disk.
  2. Quit the listed app if it is yours and safe to close.
  3. Wait for Spotlight/backup jobs to finish when they are the culprit.
  4. Use Finder or Disk Utility eject. eject-doctor v0.1.0 never ejects for you.
EOF
}

cmd_doctor() {
  local target="${1:-}"
  if [[ -z "$target" ]]; then
    echo "Missing volume path." >&2
    usage
    return 2
  fi
  if [[ ! -d "$target" ]]; then
    echo "Not a directory: $target" >&2
    return 2
  fi
  if [[ "$target" != /Volumes/* ]]; then
    say_warn "target is not under /Volumes; continuing read-only because you explicitly passed it"
  fi
  echo "Eject Doctor report for: $target"
  echo "Safety: read-only; no sudo, no kill, no unmount, no force eject."
  echo
  print_diskutil_info "$target"
  echo
  print_processes "$target"
  echo
  print_known_culprits
}

cmd_sample() {
  cat <<'EOF'
Eject Doctor report for: /Volumes/BackupSSD
Safety: read-only; no sudo, no kill, no unmount, no force eject.

Disk info:
  Volume Name:              BackupSSD
  Mounted:                  Yes
  Mount Point:              /Volumes/BackupSSD
  File System Personality:  APFS
  Ejectable:                Yes

Likely open files/processes touching this volume:
  COMMAND                PID      USER         PATH
  Finder                 431      mustafa      /Volumes/BackupSSD/Invoices
  mds_stores             812      root         /Volumes/BackupSSD/.Spotlight-V100

Common macOS eject blockers to check manually:
  - Finder window open inside the volume
  - Spotlight indexing (mds, mdworker, mds_stores)
  - backup/migration tools (backupd, systemmigrationd)
  - menu bar/system monitors (iStat, MenuBar Stats, antivirus scanners)
  - media/indexing apps previewing files from the disk

Safe next steps:
  1. Close Finder tabs/windows showing the disk.
  2. Quit the listed app if it is yours and safe to close.
  3. Wait for Spotlight/backup jobs to finish when they are the culprit.
  4. Use Finder or Disk Utility eject. eject-doctor v0.1.0 never ejects for you.
EOF
}

main() {
  local cmd="${1:-help}"
  case "$cmd" in
    list) print_volume_list ;;
    doctor) shift; cmd_doctor "${1:-}" ;;
    sample|demo) cmd_sample ;;
    help|-h|--help) usage ;;
    version|-v|--version) echo "eject-doctor ${VERSION}" ;;
    *) echo "Unknown command: $cmd" >&2; usage; return 2 ;;
  esac
}

main "$@"
