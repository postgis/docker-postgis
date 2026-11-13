#!/usr/bin/env python3
"""Exercise update deduplication and release gates."""
import importlib.util
import io
import json
import os
from pathlib import Path
import runpy
from urllib.error import HTTPError, URLError
from unittest.mock import patch

path = Path(__file__).resolve().parents[1] / '.github/scripts/update-policy.py'
spec = importlib.util.spec_from_file_location('update_policy', path)
policy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(policy)

state = {}
pending = lambda run: ('in_progress', None)
passed = lambda run: ('completed', 'success')
failed = lambda run: ('completed', 'failure')
assert policy.select_candidate(state, 'image', 'a', '1', pending)
assert not policy.select_candidate(state, 'image', 'a', '2', pending)
assert policy.select_candidate(state, 'image', 'a', '1', pending)
assert policy.select_candidate(state, 'image', 'a', '2', failed)
assert policy.select_candidate(state, 'image', 'b', '3', passed)
assert not policy.select_candidate(state, 'image', 'b', '4', passed)

assert not policy.security_environment_is_protected({})
assert not policy.security_environment_is_protected({'protection_rules': [{'type': 'required_reviewers', 'reviewers': []}]})
assert policy.security_environment_is_protected({'can_admins_bypass': False, 'protection_rules': [{'type': 'required_reviewers', 'reviewers': [{'type': 'User'}]}]})
assert not policy.routine_environment_is_protected({'protection_rules': [{'type': 'wait_timer', 'wait_timer': 4319}]})
assert policy.routine_environment_is_protected({'can_admins_bypass': False, 'protection_rules': [{'type': 'wait_timer', 'wait_timer': 4320}]})

run = {'status': 'completed'}
jobs = [{'name': name, 'status': 'completed', 'conclusion': 'success', 'steps': []}
        for name in ('Publish image', 'Verify published image')]
assert policy.published_status(run, jobs, 'image') == ('completed', 'success')
assert policy.published_status(run, jobs[:1], 'image') == ('completed', 'failure')
jobs[0]['steps'] = [{'conclusion': 'failure'}]
assert policy.published_status(run, jobs, 'image') == ('completed', 'failure')
assert policy.published_status({'status': 'in_progress'}, [], 'image') == ('in_progress', None)
assert policy.published_after_run('2026-11-02T00:00:00Z', '2026-11-01T00:00:00Z')
assert not policy.published_after_run('2026-11-01T00:00:00Z', '2026-11-01T00:00:00Z')

assert not policy.security_environment_is_protected({'can_admins_bypass': True, 'protection_rules': [{'type': 'required_reviewers', 'reviewers': [{'type': 'User'}]}]})
assert not policy.routine_environment_is_protected({'protection_rules': [{'type': 'wait_timer', 'wait_timer': 4320}]})

# Exercise the release scripts with simulated GitHub and registry responses.
def run_check(script, environment, responses):
    def response(request, **kwargs):
        value = next(responses)
        if isinstance(value, Exception):
            raise value
        return io.BytesIO(json.dumps(value).encode())
    with patch.dict(os.environ, environment), patch('urllib.request.urlopen', side_effect=response):
        try:
            runpy.run_path(str(path.with_name(script)))
        except (SystemExit, HTTPError, URLError, ValueError):
            return False
    return True

for manual in (False, True):
    environment = {'IMAGES': json.dumps({'include': [{'security': manual}]}),
                   'EVENT_NAME': 'workflow_dispatch' if manual else 'schedule',
                   'GITHUB_REPOSITORY': 'test/repo'}
    rule = ({'type': 'required_reviewers', 'reviewers': [{'type': 'User'}]} if manual else
            {'type': 'wait_timer', 'wait_timer': 4320})
    protected = {'can_admins_bypass': False, 'protection_rules': [rule]}
    assert run_check('check-release-policy.py', environment, iter([protected]))
    for rejected in ({}, {**protected, 'can_admins_bypass': True},
                     {**protected, 'protection_rules': []},
                     HTTPError('https://api.github.com', 404, 'missing', {}, None),
                     URLError('unavailable')):
        assert not run_check('check-release-policy.py', environment, iter([rejected]))
    environment['IMAGES'] = json.dumps({'include': [{'security': not manual}]})
    assert not run_check('check-release-policy.py', environment, iter([]))

routine = {'IMAGES': json.dumps({'include': [{'security': False}]}), 'EVENT_NAME': 'schedule',
           'GITHUB_REPOSITORY': 'test/repo'}
assert not run_check('check-release-policy.py', routine, iter([
    {'can_admins_bypass': False, 'protection_rules': [{'type': 'wait_timer', 'wait_timer': 4319}]}]))

candidate = {'VERSION': '18-3.7', 'VARIANT': 'default', 'GITHUB_REPOSITORY': 'test/repo', 'RUN_ID': '1'}
run = {'created_at': '2026-11-02T00:00:00Z'}
for updated, allowed in [('2026-11-01T00:00:00Z', True), ('2026-11-03T00:00:00Z', False)]:
    assert run_check('check-current-candidate.py', candidate, iter([run, {'tag_last_pushed': updated}])) == allowed
assert not run_check('check-current-candidate.py', candidate, iter([run, {}]))
assert run_check('check-current-candidate.py', candidate, iter([
    run, HTTPError('https://hub.docker.com', 404, 'new tag', {}, None)]))
assert not run_check('check-current-candidate.py', candidate, iter([
    run, HTTPError('https://hub.docker.com', 500, 'unavailable', {}, None)]))
print('Release approval, cooldown, and superseded candidate checks passed')
