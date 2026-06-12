#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/eject-doctor.zsh"

zsh -n "$SCRIPT"

help_output="$(zsh "$SCRIPT" help)"
[[ "$help_output" == *"eject-doctor"* ]]
[[ "$help_output" == *"read-only"* || "$help_output" == *"Read-only"* ]]
[[ "$help_output" == *"no kill"* ]]

version_output="$(zsh "$SCRIPT" --version)"
[[ "$version_output" == "eject-doctor 0.1.0" ]]

sample_output="$(zsh "$SCRIPT" sample)"
[[ "$sample_output" == *"Eject Doctor report"* ]]
[[ "$sample_output" == *"Likely open files/processes"* ]]
[[ "$sample_output" == *"Safe next steps"* ]]
[[ "$sample_output" == *"never ejects"* ]]

list_output="$(zsh "$SCRIPT" list)"
[[ "$list_output" == *"Mounted external-style volumes"* ]]

missing_output="$(zsh "$SCRIPT" doctor 2>&1 || true)"
[[ "$missing_output" == *"Missing volume path"* ]]

if grep -Eq '(^|[[:space:];])(sudo[[:space:]]|kill[[:space:]]|killall[[:space:]]|rm[[:space:]]+-rf|umount[[:space:]]|launchctl[[:space:]])' "$SCRIPT"; then
  echo "Unsafe command pattern found in eject-doctor.zsh" >&2
  exit 1
fi

if grep -Eq 'diskutil[[:space:]]+(eject|unmount|unmountDisk)' "$SCRIPT"; then
  echo "Unsafe diskutil eject/unmount pattern found in eject-doctor.zsh" >&2
  exit 1
fi

echo "eject-doctor smoke tests passed"
