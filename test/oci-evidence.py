#!/usr/bin/env python3
"""Test OCI evidence checks without building container images."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile

checker = Path(__file__).resolve().parents[1] / '.github/scripts/oci-evidence.py'
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    blobs = {}

    def blob(value):
        data = value if isinstance(value, bytes) else json.dumps(value, separators=(',', ':')).encode()
        digest = hashlib.sha256(data).hexdigest()
        blobs[digest] = data
        return {'digest': 'sha256:' + digest, 'size': len(data)}

    config = blob(b'config')
    layer = blob(b'layer')
    image = blob({'config': config, 'layers': [layer]})
    image['platform'] = {'os': 'linux', 'architecture': 'amd64'}
    subjects = [{'digest': {'sha256': image['digest'][7:]}}]
    sbom = blob({'predicateType': 'https://spdx.dev/Document', 'subject': subjects})
    provenance = blob({'predicateType': 'https://slsa.dev/provenance/v1', 'subject': subjects})
    attestation = blob({'layers': [sbom, provenance], 'subject': {'digest': image['digest']}})
    attestation['annotations'] = {'vnd.docker.reference.type': 'attestation-manifest',
                                  'vnd.docker.reference.digest': image['digest']}
    index = blob({'manifests': [image, attestation]})
    index['annotations'] = {'org.opencontainers.image.ref.name': '3.7'}
    archive = root / 'image.tar'
    with tarfile.open(archive, 'w') as output:
        def add(name, data):
            info = tarfile.TarInfo(name)
            info.size = len(data)
            output.addfile(info, io.BytesIO(data))
        add('index.json', json.dumps({'manifests': [index]}).encode())
        for digest, data in blobs.items():
            add('blobs/sha256/' + digest, data)

    def check(architecture, loaded):
        return subprocess.run([sys.executable, str(checker), str(archive), str(root / 'evidence.json'),
                               'postgis/postgis:3.7', architecture, loaded], capture_output=True)
    assert check('amd64', index['digest']).returncode == 0
    evidence = json.loads((root / 'evidence.json').read_text())
    assert evidence['manifest']['digest'] == image['digest']
    assert evidence['attestations'] == [attestation['digest']]
    assert check('arm64', index['digest']).returncode != 0
    assert check('amd64', 'sha256:' + '0' * 64).returncode != 0
    with tarfile.open(archive) as source:
        offset = source.getmember('blobs/sha256/' + layer['digest'][7:]).offset_data
    with archive.open('r+b') as output:
        output.seek(offset)
        output.write(b'X')
    assert check('amd64', index['digest']).returncode != 0

print('OCI image and attestation checks passed')
