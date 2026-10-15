"""Check the packaged v1.2 payload, without accessing a vehicle or SD card."""
from pathlib import Path, PurePosixPath
import hashlib
import re

ROOT = Path(__file__).resolve().parent.parent


def digest(path, algorithm='sha1'):
    return hashlib.new(algorithm, path.read_bytes()).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify():
    sd = ROOT / 'SD_ROOT'
    base = sd / 'mod/rvc_p0916'
    manifest = base / 'manifest.txt'
    script = (sd / 'mod/custom.sh').read_bytes()
    require(b'\r' not in script and not script.startswith(b'\xef\xbb\xbf'),
            'custom.sh must use LF without a BOM')
    require(('matches "$MANIFEST" ' + digest(manifest) + ' ||').encode() in script,
            'Embedded manifest hash mismatch')
    require((base / 'ACTION.txt').read_bytes() == b'INSTALL\n', 'Release action must be INSTALL')
    images = ['2100002', '2100003', '2100137'] + [str(i) for i in range(2100145, 2100157)]
    expected = {'system/etc/eso/production/displaymanager.json'}
    expected.update('app/eso/hmi/lsd/images/HMIEarlyAppsEvoHighScale/' + n + '.png' for n in images)
    expected.update('app/eso/hmi/lsd/kzbs/HMISystemEvoHighScale/OPS_AU' + n + '.kzb'
                    for n in ['370', '371', '373', '375'])
    seen, changed = set(), set()
    for line in manifest.read_text(encoding='ascii').splitlines():
        fields = line.split()
        require(len(fields) == 4, 'Invalid manifest row')
        original, previous, target, rel = fields
        require(all(re.fullmatch('[0-9a-f]{40}', x) for x in fields[:3]), 'Invalid SHA-1')
        require(rel in expected and rel not in seen, 'Unexpected or duplicate resource: ' + rel)
        seen.add(rel)
        for folder, checksum in [('originals', original), ('patched', target)]:
            p = base / folder / rel
            require(p.is_file() and not p.is_symlink(), 'Missing or linked payload: ' + rel)
            require(digest(p) == checksum, 'Payload hash mismatch: ' + str(p.relative_to(ROOT)))
        if original != target:
            changed.add(PurePosixPath(rel).name)
    require(seen == expected, 'Expected exactly 20 resources')
    require(changed == {'displaymanager.json', '2100002.png', '2100003.png'}, 'Unexpected v1.2 changes')
    for folder in ('originals', 'patched'):
        actual = {p.relative_to(base / folder).as_posix() for p in (base / folder).rglob('*') if p.is_file()}
        require(actual == expected, 'Extra or missing files in ' + folder)
    sd_files = {p.relative_to(ROOT).as_posix(): p for p in sd.rglob('*') if p.is_file()}
    require(len(sd_files) == 43, 'Expected 43 SD_ROOT files')
    checked = set()
    for line in (ROOT / 'PAYLOAD_SHA256SUMS.txt').read_text(encoding='ascii').splitlines():
        checksum, rel = line.split('  ', 1)
        require(rel in sd_files and rel not in checked, 'Invalid SHA-256 entry')
        require(digest(sd_files[rel], 'sha256') == checksum, 'SHA-256 mismatch: ' + rel)
        checked.add(rel)
    require(checked == set(sd_files), 'Incomplete SHA-256 inventory')
    print('PASS: 20 resources, 17 stock / 3 modified; 43 SD_ROOT files verified.')


if __name__ == '__main__':
    verify()
