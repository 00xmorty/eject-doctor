#!/usr/bin/env python3
"""Regression checks with real lsof and an owned open file, not a real disk.

Writes only temporary fixtures under BH/Eject scratch. No mount/eject/kill.
Usage: python3 tests/test_live_doctor.py [path/to/eject-doctor.zsh]
"""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(sys.argv.pop(1)).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1] / 'eject-doctor.zsh'
SCRATCH = Path(os.environ.get('EJECT_DOCTOR_TEST_TMPDIR', str(Path.home() / '.hermes/cache/scratch')))
SCRATCH.mkdir(parents=True, exist_ok=True)

class LiveDoctorRegression(unittest.TestCase):
    def check_open_file(self, directory_name, filename):
        with tempfile.TemporaryDirectory(prefix='eject-doctor-regression-', dir=SCRATCH) as temporary:
            target = Path(temporary) / directory_name
            target.mkdir()
            held = target / filename
            held.write_text('Controlled diagnostic fixture, not user data.\n')
            with held.open('r'):
                result = subprocess.run(['zsh', str(SCRIPT), 'doctor', str(target)], capture_output=True, text=True, timeout=45)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(str(held), result.stdout, 'Full file path must survive spaces and shell metacharacters')
            self.assertIn(str(os.getpid()), result.stdout, 'Real lsof must identify the fixture-owning process')
            self.assertIn('Safe next steps:', result.stdout)
            self.assertNotIn('command not found', result.stderr)
            self.assertIn('no sudo, no kill, no unmount, no force eject', result.stdout)

    def test_matching_open_file_keeps_command_lookup_working(self):
        self.check_open_file('live-probe', 'held-file.txt')

    def test_full_path_with_spaces_and_brackets(self):
        self.check_open_file('Live probe [fixture]', 'held file.txt')

    def test_empty_target_still_prints_next_steps(self):
        with tempfile.TemporaryDirectory(prefix='eject-doctor-empty-', dir=SCRATCH) as target:
            result = subprocess.run(['zsh', str(SCRIPT), 'doctor', target], capture_output=True, text=True, timeout=45)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('none visible to current user', result.stdout)
        self.assertIn('Safe next steps:', result.stdout)

if __name__ == '__main__':
    unittest.main(verbosity=2)
