#!/usr/bin/env python3
"""Verify the exact vendored source inventory without importing target code."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
for package in json.loads((root / 'Vendor/provenance.json').read_text()):
    directory = root / 'Vendor' / package['name']
    actual = {}
    for path in sorted(directory.rglob('*')):
        if path.is_symlink():
            raise SystemExit(f'Symlink is not allowed: {path}')
        if path.is_file():
            actual[str(path.relative_to(directory))] = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != package['files']:
        raise SystemExit(f'Vendor content changed: {package["name"]}; review before building')
    print(f'Verified {package["name"]} {package["version"]} ({package["revision"]})')
