#!/usr/bin/env python3
"""Fail closed if a release environment lacks its required protection."""
import importlib.util
import json
import os
from pathlib import Path

spec = importlib.util.spec_from_file_location('update_policy', Path(__file__).with_name('update-policy.py'))
policy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(policy)
images = json.loads(os.environ['IMAGES'])['include']
manual = os.environ['EVENT_NAME'] == 'workflow_dispatch'
if any(image.get('security') is not manual for image in images):
    raise SystemExit('Release approval metadata does not match the workflow event')
needed = set()
if any(image.get('security') for image in images):
    needed.add('postgis-security')
if os.environ['EVENT_NAME'] == 'schedule' and any(not image.get('security') for image in images):
    needed.add('postgis-routine')
for name in sorted(needed):
    environment = policy.request_json(f"https://api.github.com/repos/{os.environ['GITHUB_REPOSITORY']}/environments/{name}",
                                      token=os.environ.get('GH_TOKEN'))
    protected = (policy.security_environment_is_protected(environment) if name == 'postgis-security'
                 else policy.routine_environment_is_protected(environment))
    if not protected:
        raise SystemExit(f'{name} lacks the required release protection')
    print(f'{name} has the required release protection')
