#!/usr/bin/env python3
"""Stop a delayed candidate from replacing an image published since its run began."""
import importlib.util
import os
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import quote

spec = importlib.util.spec_from_file_location('update_policy', Path(__file__).with_name('update-policy.py'))
policy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(policy)
tag = os.environ['VERSION'] + ('-alpine' if os.environ['VARIANT'] == 'alpine' else '')
run = policy.request_json(f"https://api.github.com/repos/{os.environ['GITHUB_REPOSITORY']}/actions/runs/{os.environ['RUN_ID']}",
                          token=os.environ.get('GH_TOKEN'))
try:
    image = policy.request_json('https://hub.docker.com/v2/repositories/postgis/postgis/tags/' + quote(tag, safe='') + '/')
except HTTPError as error:
    if error.code != 404:
        raise
else:
    updated = image.get('tag_last_pushed') or image.get('last_updated')
    if not updated:
        raise SystemExit(f'No publication timestamp for {tag}')
    if policy.published_after_run(updated, run['created_at']):
        raise SystemExit(f'{tag} was published after this candidate was selected')
