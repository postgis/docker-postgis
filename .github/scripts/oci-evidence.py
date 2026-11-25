#!/usr/bin/env python3
"""Check the tested OCI image and record its immutable descriptors."""
import hashlib
import json
import sys
import tarfile

archive, output, tag, architecture, loaded_id = sys.argv[1:]

with tarfile.open(archive, 'r:*') as layout:
    def read_blob(descriptor, capture=False):
        digest = descriptor['digest']
        if not digest.startswith('sha256:'):
            raise ValueError(f'unsupported digest: {digest}')
        checksum = hashlib.sha256()
        data = bytearray() if capture else None
        size = 0
        with layout.extractfile('blobs/' + digest.replace(':', '/')) as source:
            while chunk := source.read(1024 * 1024):
                checksum.update(chunk)
                size += len(chunk)
                if capture:
                    data.extend(chunk)
        if size != descriptor['size'] or checksum.hexdigest() != digest[7:]:
            raise ValueError(f'invalid blob: {digest}')
        return data

    def read_json(descriptor):
        return json.loads(read_blob(descriptor, capture=True))

    index = json.load(layout.extractfile('index.json'))
    refs = [item for item in index['manifests']
            if item.get('annotations', {}).get('org.opencontainers.image.ref.name') == tag.split(':', 1)[1]]
    if len(refs) != 1:
        raise ValueError(f'expected one OCI reference for {tag}')
    root = refs[0]
    manifests = read_json(root)['manifests']
    images = [item for item in manifests if item.get('platform', {}).get('os') == 'linux'
              and item.get('platform', {}).get('architecture') == architecture]
    if len(images) != 1:
        raise ValueError(f'expected one linux/{architecture} image')
    image = images[0]
    manifest = read_json(image)
    config = manifest['config']
    read_blob(config)
    if loaded_id not in (root['digest'], config['digest']):
        raise ValueError('loaded image does not match the OCI archive')
    if not manifest['layers']:
        raise ValueError('image has no layers')
    for layer in manifest['layers']:
        read_blob(layer)

    predicates = set()
    attestations = []
    for descriptor in manifests:
        annotations = descriptor.get('annotations', {})
        if annotations.get('vnd.docker.reference.type') != 'attestation-manifest':
            continue
        if annotations.get('vnd.docker.reference.digest') != image['digest']:
            raise ValueError('attestation refers to a different image')
        attestation = read_json(descriptor)
        if attestation.get('subject', {}).get('digest', image['digest']) != image['digest']:
            raise ValueError('attestation subject does not match image')
        for layer in attestation['layers']:
            statement = read_json(layer)
            if not any(subject.get('digest', {}).get('sha256') == image['digest'][7:]
                       for subject in statement.get('subject', [])):
                raise ValueError('attestation statement refers to a different image')
            predicates.add(statement['predicateType'])
        attestations.append(descriptor['digest'])
    if not any(value.startswith('https://slsa.dev/provenance/') for value in predicates):
        raise ValueError('missing provenance attestation')
    if 'https://spdx.dev/Document' not in predicates:
        raise ValueError('missing SBOM attestation')

    with open(output, 'w') as stream:
        json.dump({'tag': tag, 'platform': ['linux', architecture], 'index': root,
                   'manifest': image, 'config': config, 'layers': manifest['layers'],
                   'attestations': attestations}, stream, separators=(',', ':'))
