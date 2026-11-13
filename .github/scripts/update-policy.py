#!/usr/bin/env python3
"""Select changed candidates and check release gates."""
import hashlib
import json
from pathlib import Path
from datetime import datetime
import urllib.request


def request_json(url, token=None):
    headers = {'Accept': 'application/vnd.github+json', 'User-Agent': 'docker-postgis-update-check'}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=30) as response:
        return json.load(response)


def candidate_fingerprint(version, variant, base_times, root=Path('.')):
    digest = hashlib.sha256()
    dockerfile = root / version / ('alpine/Dockerfile' if variant == 'alpine' else 'Dockerfile')
    paths = [dockerfile, root / 'initdb-postgis.sh', root / 'update-postgis.sh', root / '.dockerignore', root / 'docker-bake.hcl']
    if variant == 'alpine':
        paths.append(root / version / 'alpine/pgrouting-version.txt')
    for path in paths:
        if path.is_file():
            digest.update(str(path.relative_to(root)).encode() + b'\0' + path.read_bytes() + b'\0')
    digest.update(json.dumps(base_times, sort_keys=True).encode())
    return digest.hexdigest()


def select_candidate(state, name, fingerprint, run_id, previous_status):
    """Suppress a candidate while its prior run is pending or succeeded."""
    previous = state.get(name, {})
    if previous.get('run_id') and str(previous['run_id']) != str(run_id):
        status, conclusion = previous_status(previous['run_id'])
        if previous.get('fingerprint') == fingerprint and (status != 'completed' or conclusion == 'success'):
            return False
    state[name] = {'fingerprint': fingerprint, 'run_id': run_id}
    return True


def published_status(run, jobs, image_name):
    if run['status'] != 'completed':
        return run['status'], None
    required = {f'Publish {image_name}', f'Verify published {image_name}'}
    passed = {job['name'] for job in jobs if job['status'] == 'completed'
              and job['conclusion'] == 'success'
              and all(step.get('conclusion') != 'failure' for step in job.get('steps', []))}
    return 'completed', 'success' if required <= passed else 'failure'


def published_after_run(updated, created):
    return datetime.fromisoformat(updated.replace('Z', '+00:00')) > datetime.fromisoformat(created.replace('Z', '+00:00'))


def security_environment_is_protected(environment):
    return environment.get('can_admins_bypass') is False and any(rule.get('type') == 'required_reviewers' and rule.get('reviewers')
               for rule in environment.get('protection_rules', []))


def routine_environment_is_protected(environment):
    return environment.get('can_admins_bypass') is False and any(rule.get('type') == 'wait_timer' and rule.get('wait_timer', 0) >= 4320
               for rule in environment.get('protection_rules', []))
