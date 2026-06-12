# Eject Doctor

<p align="center">
  <img src="assets/demo.gif" alt="Eject Doctor terminal demo" width="860">
</p>

<p align="center">
  <a href="https://github.com/00xmorty/eject-doctor/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/00xmorty/eject-doctor/actions/workflows/ci.yml/badge.svg"></a>
  <img alt="release" src="https://img.shields.io/badge/release-v0.1.0-brightgreen">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="platform" src="https://img.shields.io/badge/platform-macOS-lightgrey">
  <img alt="language" src="https://img.shields.io/badge/language-zsh-89e051">
</p>

A tiny read-only macOS CLI that explains why an external disk refuses to eject.

## Why this exists

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

```sh
git clone https://github.com/00xmorty/eject-doctor.git
cd eject-doctor
chmod +x eject-doctor.zsh
```

Optional PATH install:

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
# eject-doctor 0.1.0
```

## Safety model

| Behavior | v0.1.0 |
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

- macOS
- zsh
- Built-ins usually present on macOS: `diskutil`, `df`, `lsof`, `awk`, `sort`, `head`

## Tests

```sh
bash tests/smoke.sh
```

The smoke test checks syntax, help/version/sample/list commands, missing-argument behavior, and obvious destructive command patterns.

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

Because forced eject/unmount is exactly where data-loss risk starts. v0.1.0 is intentionally diagnostic only.

### Why are some processes missing?

`lsof` visibility depends on permissions and process ownership. Eject Doctor avoids sudo, so some system-owned processes may need Activity Monitor or Disk Utility for manual inspection.

### Does it inspect my files?

No. It reports visible open paths/process names; it does not read file contents.

## Contributing

Small, safety-preserving improvements are welcome. Please keep v0.x behavior read-only unless a future release clearly separates opt-in actions with explicit confirmation.

## License

MIT
