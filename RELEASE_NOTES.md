# v0.1.1

Patch release for read-only diagnostic reliability.

## Fixes
- Keep the full diagnostic report working after finding an open file. Avoid assigning to zsh's special `path` parameter, which changed command lookup and broke the final guidance with `command not found: cat`.
- Preserve full open-file paths containing spaces instead of reporting only the last word.
- Add three real `lsof` regression checks: an owned open file, a filename/directory with spaces and brackets, and an empty target. CI runs these checks in addition to smoke tests.

## Safety and limits
Read-only behavior is unchanged: no sudo, no process termination, no eject/unmount, no background daemon. A report shows a limited snapshot of paths visible to the current user, not proof of the sole cause of an eject failure.

Regression checks use controlled temporary files and real `lsof`; they do not mount a drive or reproduce a real external-disk eject failure. No broader macOS compatibility matrix is claimed.

## Verification
Run `bash tests/smoke.sh` and `python3 tests/test_live_doctor.py` on macOS. Both suites are included in GitHub Actions. The new live checks supplement the static sample-output smoke tests; they are not a claim that every disk-ejection problem is fixed.
