"""Build a deterministic installation archive using only the Python standard library."""
from pathlib import Path
import hashlib
import zipfile
from verify import ROOT, verify


def main():
    verify()
    dist = ROOT / 'dist'
    dist.mkdir(exist_ok=True)
    archive = dist / 'Audi-MHI2-P0916-RVC-MIB-v1.2.zip'
    files = [p for p in (ROOT / 'SD_ROOT').rglob('*') if p.is_file()]
    files += [ROOT / n for n in ['README.md', 'NOTICE.md', 'CHANGELOG.md',
                                 'RELEASE_NOTES.md', 'PAYLOAD_SHA256SUMS.txt']]
    files += [p for p in (ROOT / 'docs').rglob('*') if p.is_file()]
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
        for path in sorted(files):
            info = zipfile.ZipInfo(path.relative_to(ROOT).as_posix(), (2026, 10, 16, 0, 0, 0))
            info.create_system = 3
            info.external_attr = (0o100755 if path.suffix == '.sh' else 0o100644) << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(info, path.read_bytes())
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:
            raise ValueError('ZIP verification failed')
    checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix('.sha256.txt').write_text(checksum + '  ' + archive.name + '\n', encoding='ascii')
    print('Built:', archive.name)


if __name__ == '__main__':
    main()
