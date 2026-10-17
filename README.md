Eject Doctor helps Mac users identify visible processes holding a disk open when Finder refuses to eject it.

# eject-doctor

![Terminal demo — example output](assets/demo.gif)

## Install

In an empty directory, download the single executable release asset and make it executable:

```sh
curl -fsSLO https://github.com/00xmorty/eject-doctor/releases/download/v0.1.1/eject-doctor.zsh && chmod +x eject-doctor.zsh
```

This downloads a file; it does not execute a remote install script or change your PATH. Review it before running. [Release and asset](https://github.com/00xmorty/eject-doctor/releases/tag/v0.1.1) · [Source](./eject-doctor.zsh).

## Usage

```sh
./eject-doctor.zsh list
./eject-doctor.zsh doctor "/Volumes/My Disk"
./eject-doctor.zsh sample
```

## Example output

Illustrative fixture data; paths, process IDs, timings and sizes are examples, not claims about your Mac.

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
  4. Use Finder or Disk Utility eject. eject-doctor v0.1.1 never ejects for you.
```

## Requirements

- macOS 26.6.2 verified; older releases have not been verified in this preparation pass.
- zsh and the macOS diskutil, df, lsof, awk, sort and head tools.
- No sudo or package manager is required to run the diagnostic.

## Safety and limits

Read-only diagnostics: no deletion, settings changes, background agent, process termination or automatic repair. It does not read file contents. No telemetry or network calls are made by the diagnostic. Downloading with curl is a separate install step.

Process visibility depends on your permissions. An open file is a clue, not proof that force eject is safe. Close the responsible application yourself; this tool does not eject disks or stop processes.

Review reports before sharing: local paths and process names may be sensitive. The GIF shows an example; sample/fixture mode does not diagnose your current machine.

## Development

```sh
bash tests/smoke.sh
```

## License

[MIT](LICENSE).
