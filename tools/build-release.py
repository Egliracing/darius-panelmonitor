#!/usr/bin/env python3
"""Build self-contained Plasma package and source archive; no network access."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib
import json

project = Path(__file__).resolve().parents[1]
version = json.loads((project / 'package/metadata.json').read_text())['KPlugin']['Version']
release = project / 'store'
release.mkdir(exist_ok=True)
package_name = f'Darius-Panelmonitor-{version}.plasmoid'
source_name = f'Darius-Panelmonitor-{version}-source.zip'
with ZipFile(release / package_name, 'w', ZIP_DEFLATED) as archive:
    for file in sorted((project / 'package').rglob('*')):
        if file.is_file():
            archive.write(file, file.relative_to(project / 'package'))
(project / 'Darius-Panelmonitor.plasmoid').write_bytes((release / package_name).read_bytes())
with ZipFile(release / source_name, 'w', ZIP_DEFLATED) as archive:
    for directory in ['package', 'translations', 'tests', 'tools', 'store']:
        for file in sorted((project / directory).rglob('*')):
            if not file.is_file() or file.suffix in ['.zip', '.plasmoid'] or file.name == 'SHA256SUMS':
                continue
            archive.write(file, Path(f'Darius-Panelmonitor-{version}') / file.relative_to(project))
    for name in ['README.md', 'LICENSE', 'COPYRIGHT', 'ANLEITUNG.md', 'installieren.sh']:
        archive.write(project / name, Path(f'Darius-Panelmonitor-{version}') / name)
(release / 'SHA256SUMS').write_text(''.join(
    hashlib.sha256((release / name).read_bytes()).hexdigest() + '  ' + name + '\n'
    for name in [package_name, source_name]))
print(f'Built {package_name} and {source_name}')
