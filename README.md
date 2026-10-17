# Eject Doctor

Eject Doctor helps Mac users identify visible processes holding a disk open when Finder refuses to eject it.

<p align="center">
  <img src="assets/demo.gif" alt="Eject Doctor terminal demo" width="860">
</p>

The GIF uses illustrative data and a neutral shell. Reproduce with `vhs demo.tape` (VHS required).


<p align="center">
  <a href="https://github.com/00xmorty/eject-doctor/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/00xmorty/eject-doctor/actions/workflows/ci.yml/badge.svg"></a>
  <img alt="release" src="https://img.shields.io/badge/release-v0.1.2-brightgreen">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="platform" src="https://img.shields.io/badge/platform-macOS-lightgrey">
  <img alt="language" src="https://img.shields.io/badge/language-zsh-89e051">
</p>

## Why this exists

Instead of interpreting raw `lsof` output yourself, Eject Doctor combines visible open paths, disk metadata and manual next steps in one report. It helps you investigate before considering a risky force eject; it never performs one.

macOS often says an external drive is “in use” without naming the process. That leaves people rebooting, force-ejecting, or guessing. Eject Doctor answers a narrower question:

> What visible process or file path is touching this volume right now, and what should I close safely?

## Highlights

- Read-only by design: no sudo, no kill, no unmount, no force eject.
- Lists mounted volumes under `/Volumes`.
- Shows useful `diskutil info` metadata for the selected disk.
- Uses a non-recursive `lsof` scan to avoid slow full-disk walks.
- Explains common culprits: Finder, Spotlight, backup/migration jobs, menu bar monitors, antivirus/media indexers.
- Includes deterministic `sample` output for quick understanding and smoke tests.

## Install

In an empty directory, download the single executable release asset and make it executable:

```sh
curl -fsSLO https://github.com/00xmorty/eject-doctor/releases/download/v0.1.2/eject-doctor.zsh && chmod +x eject-doctor.zsh
```

This downloads a file; it does not execute a remote install script or change your PATH. Review it before running. [Release and asset](https://github.com/00xmorty/eject-doctor/releases/tag/v0.1.2) · [Source](./eject-doctor.zsh).

For a source checkout:

```sh
git clone https://github.com/00xmorty/eject-doctor.git
cd eject-doctor
./eject-doctor.zsh list
```

Optional user-local PATH install (add `~/bin` to your shell PATH):

```sh
mkdir -p ~/bin
cp eject-doctor.zsh ~/bin/eject-doctor
```

## Quick start

```sh
./eject-doctor.zsh list
./eject-doctor.zsh doctor /Volumes/MyDisk
./eject-doctor.zsh sample
```

## Example output

Illustrative output with anonymized users; paths and process IDs are examples, not measurements of your Mac.

```text
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
  Finder                 431      you          /Volumes/BackupSSD/Invoices
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
  4. Use Finder or Disk Utility eject. eject-doctor v0.1.2 never ejects for you.
```

## Command reference

### `list`

Shows mounted external-style volumes under `/Volumes`.

```sh
./eject-doctor.zsh list
```

### `doctor /Volumes/MyDisk`

Prints a read-only diagnostic report for the selected volume.

```sh
./eject-doctor.zsh doctor /Volumes/BackupSSD
```

### `sample`

Prints deterministic demo output without needing an external disk attached.

```sh
./eject-doctor.zsh sample
```

### `--version`

```sh
./eject-doctor.zsh --version
# eject-doctor 0.1.2
```

## Safety model

No network requests or telemetry. Reports can expose local paths and process names; review them before sharing. The GIF and example show illustrative data, not the current state of your Mac.

| Behavior | v0.1.2 |
| --- | --- |
| Uses `sudo` | No |
| Kills processes | No |
| Ejects/unmounts disks | No |
| Force eject | No |
| Background daemon | No |
| Reads file contents | No |
| Lists visible open paths/processes | Yes |

If Eject Doctor shows a process, close or quit it manually only when you understand what it is doing. Use Finder or Disk Utility for ejecting.

## Requirements

- Tested on macOS 26.6.2.
- zsh
- Built-ins usually present on macOS: `diskutil`, `df`, `lsof`, `awk`, `sort`, `head`

## Tests

```sh
bash tests/smoke.sh
python3 tests/test_live_doctor.py
```

The smoke test checks syntax, help/version/sample/list commands, missing-argument behavior, and obvious destructive command patterns.
The regression tests use real `lsof` with controlled open files to verify complete reports and full paths containing spaces. They do not mount or eject a disk. Python 3 is needed only for this development test suite.

## Design principles

- Explain first, never mutate by default.
- Prefer clear manual next steps over automation that could corrupt data.
- Avoid recursive disk scans that can hang on large drives.
- Keep the tool small enough to audit in one sitting.

## Roadmap

- `--json` output for automation.
- Richer known-process explanations.
- Safer filters for very large multi-user systems.

## FAQ

### Why does it not eject the disk for me?

Because forced eject/unmount is exactly where data-loss risk starts. v0.1.2 is intentionally diagnostic only.

### Why are some processes missing?

`lsof` visibility depends on permissions and process ownership. Eject Doctor avoids sudo, so some system-owned processes may need Activity Monitor or Disk Utility for manual inspection.

### Does it inspect my files?

No. It reports visible open paths/process names; it does not read file contents.

## Contributing

Small, safety-preserving improvements are welcome. Please keep v0.x behavior read-only unless a future release clearly separates opt-in actions with explicit confirmation.

## License

[MIT](LICENSE).
