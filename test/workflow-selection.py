#!/usr/bin/env python3
"""Check the image selector without running Docker or contacting Docker Hub."""

import ast
from contextlib import chdir
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tempfile
import textwrap


root = Path(__file__).resolve().parents[1]
workflow = (root / ".github/workflows/docker.yml").read_text()
publish = workflow.split("\n  publish:\n", 1)[1].split("\n  verify-published:\n", 1)[0]
assert "github.repository == 'postgis/docker-postgis'" in publish
assert "github.ref == 'refs/heads/master'" in publish
assert "github.event_name == 'workflow_dispatch' && inputs.mode == 'release'" in publish
assert "needs.verify-build.outputs.has_images == 'true'" in publish
assert "needs: [versions, verify-build, release-policy]" in publish
assert "environment: ${{ matrix.security && 'postgis-security'" in publish
assert publish.index('Recheck release protection after waiting') < publish.index('Login to Docker Hub')
assert publish.index('Check that the candidate is still current') < publish.index('Login to Docker Hub')
current_check = publish.split('Check that the candidate is still current', 1)[1].split('run:', 1)[0]
assert "github.event_name == 'schedule'" in current_check
assert "inputs.mode == 'release'" in current_check
start = workflow.index("          python3 - <<'PY' >> \"$GITHUB_OUTPUT\"\n")
script = workflow[start:].split("\n          PY\n", 1)[0].split("\n", 1)[1]
script = textwrap.dedent(script)
functions = [node for node in ast.parse(script).body if isinstance(node, ast.FunctionDef) and node.name in {
    "meaningful_diff", "meaningful_worktree_change", "meaningful_commit_after",
}]
namespace = {"subprocess": subprocess, "PurePosixPath": PurePosixPath}
exec(compile(ast.Module(body=functions, type_ignores=[]), "<selector>", "exec"), namespace)
meaningful_diff = namespace["meaningful_diff"]
assert not meaningful_diff("+ # changed comment\n- # old comment\n")
assert not meaningful_diff("+   \n")
assert meaningful_diff("+RUN echo changed\n")
assert meaningful_diff("new file mode 100644\n")


def select(event, cwd=root, **overrides):
    env = os.environ.copy()
    env.update(EVENT_NAME=event, REF="refs/heads/master")
    env.update(overrides)
    output = subprocess.check_output([sys.executable, "-c", script], cwd=cwd, env=env, text=True)
    values = dict(line.split("=", 1) for line in output.splitlines())
    return values, {(item["version"], item["variant"]) for item in json.loads(values["images"])["include"]}


push, targets = select("push")
assert push["latest_version"] == "18-3.7"
assert targets and all(version.endswith("-master") for version, _ in targets)

dispatch, targets = select("workflow_dispatch")
_, one_target = select("workflow_dispatch", DISPATCH_IMAGE="18-3.7-alpine")
assert one_target == {("18-3.7", "alpine")}
invalid = subprocess.run([sys.executable, "-c", script], cwd=root, capture_output=True,
                         env={**os.environ, "EVENT_NAME": "workflow_dispatch", "REF": "refs/heads/master", "DISPATCH_IMAGE": "missing"})
assert invalid.returncode != 0
failed_update = subprocess.run([sys.executable, "-c", script], cwd=root, capture_output=True,
                               env={**os.environ, "EVENT_NAME": "workflow_dispatch", "REF": "refs/heads/master",
                                    "DISPATCH_MODE": "release", "UPDATE_SCRIPT_OUTCOME": "failure"})
assert failed_update.returncode != 0
_, release_target = select("workflow_dispatch", DISPATCH_MODE="release", UPDATE_SCRIPT_OUTCOME="success", DISPATCH_IMAGE="18-3.7")
assert release_target == {("18-3.7", "default")}
release, _ = select("workflow_dispatch", DISPATCH_MODE="release", UPDATE_SCRIPT_OUTCOME="success", DISPATCH_IMAGE="18-3.7")
assert all(image["security"] for image in json.loads(release["images"])["include"])
assert not any(image["security"] for image in json.loads(push["images"])["include"])
assert {("19rc2-3.7", "default"), ("19rc2-3.7", "alpine")} <= targets
experimental = {(item["version"], item["variant"]): item["experimental"] for item in json.loads(dispatch["images"])["include"]}
assert not experimental["18-3.7", "default"] and not experimental["18-3.7", "alpine"]
assert all(experimental[target] for target in (("16-master", "default"), ("19rc2-3.7", "default"), ("19rc2-3.7", "default")))
assert not experimental["18-3.7", "default"] and not experimental["18-3.7", "alpine"]

# Exercise the scheduled path without network calls.
with tempfile.TemporaryDirectory() as directory:
    state_file = str(Path(directory) / 'state.json')
    scheduled = script.replace('/tmp/postgis-update-state.json', state_file)
    scheduled = scheduled.replace('if event_name == "push" and ref == "refs/heads/master":',
        'stale_targets_from_base_updates = lambda targets: {( "18-3.7", "default" )}\n'
        'dockerhub_last_updated = lambda *args: datetime.fromisoformat("2026-01-01T00:00:00+00:00")\n'
        'if event_name == "push" and ref == "refs/heads/master":', 1)
    scheduled = scheduled.replace('state = json.loads(state_file.read_text()) if state_file.exists() else {}',
        'state = json.loads(state_file.read_text()) if state_file.exists() else {}\n    policy.request_json = lambda *args, **kwargs: {"status": "in_progress"}')
    env = {**os.environ, 'EVENT_NAME': 'schedule', 'REF': 'refs/heads/master',
           'UPDATE_SCRIPT_OUTCOME': 'success', 'RUN_ID': '1', 'REPOSITORY': 'test/repo'}
    first = subprocess.check_output([sys.executable, '-c', scheduled], cwd=root, env=env, text=True)
    image = json.loads(dict(line.split('=', 1) for line in first.splitlines())['images'])['include'][0]
    assert image['version'] == '18-3.7' and not image['security']
    env['RUN_ID'] = '2'
    second = subprocess.check_output([sys.executable, '-c', scheduled], cwd=root, env=env, text=True)
    assert dict(line.split('=', 1) for line in second.splitlines())['has_images'] == 'false'
    env['UPDATE_SCRIPT_OUTCOME'] = 'failure'
    assert subprocess.run([sys.executable, '-c', scheduled], cwd=root, env=env, capture_output=True).returncode != 0

manual_workflow = (root / ".github/workflows/main.yml").read_text()
assert "make push" not in manual_workflow and "docker/login-action" not in manual_workflow
manual_script = textwrap.dedent(manual_workflow.split("          python3 - <<'PYTHON' >> \"$GITHUB_OUTPUT\"\n", 1)[1].split("\n          PYTHON", 1)[0])
def manual_matrix(cwd):
    output = subprocess.check_output([sys.executable, "-c", manual_script], cwd=cwd, text=True)
    return json.loads(output.removeprefix("matrix="))["include"]

manual = manual_matrix(root)
assert {(row["postgres"] + "-" + row["postgis"], row["variant"]) for row in manual} == targets
assert len(manual) == 2 * len(targets)
assert any(row["postgres"] == "19rc2" and row["postgis"] == "master" and row["variant"] == "alpine" for row in manual)
with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    (fixture / "18-3.7").mkdir()
    dockerfile = fixture / "18-3.7/Dockerfile"
    dockerfile.write_text("ENV POSTGIS_VERSION=3.7.0rc3\n")
    assert all(row["experimental"] for row in manual_matrix(fixture))
    dockerfile.write_text("ENV POSTGIS_VERSION=3.7.0\n")
    assert not any(row["experimental"] for row in manual_matrix(fixture))

verifier = workflow.split("\n  verify-build:\n", 1)[1].split("\n  publish:\n", 1)[0]
verifier = textwrap.dedent(verifier.split("          python3 - <<'PY' >> \"$GITHUB_OUTPUT\"\n", 1)[1].split("\n          PY", 1)[0])
with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    stable = {"version": "18-3.7", "variant": "default", "experimental": False}
    preview = {"version": "19rc2-3.7", "variant": "default", "experimental": True}
    def evidence(image, arch):
        path = fixture / f"evidence/postgis-evidence-{image['version']}-default-{arch}/image.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"tag": f"postgis/postgis:{image['version']}", "platform": ["linux", arch],
                                   "index": {"digest": "sha256:" + "3" * 64}, "attestations": ["sha256:" + "4" * 64],
                                   "manifest": {"digest": "sha256:" + "1" * 64}, "config": {"digest": "sha256:" + "2" * 64}, "layers": [1]}))
        return path
    def verify(images):
        return subprocess.run([sys.executable, "-c", verifier], cwd=fixture, text=True, capture_output=True,
                              env={**os.environ, "IMAGES": json.dumps({"include": images})})
    evidence(stable, "amd64")
    stable_arm = evidence(stable, "arm64")
    result = verify([stable, preview])
    assert result.returncode == 0 and json.loads(result.stdout.splitlines()[0].split("=", 1)[1])["include"] == [stable]
    assert "has_images=false" in verify([preview]).stdout
    evidence(preview, "amd64")
    preview_arm = evidence(preview, "arm64")
    assert json.loads(verify([stable, preview]).stdout.splitlines()[0].split("=", 1)[1])["include"] == [stable, preview]
    preview_arm.write_text("invalid JSON")
    assert verify([stable, preview]).returncode == 0
    stable_arm.unlink()
    assert verify([stable, preview]).returncode != 0

with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    (fixture / "Makefile").write_text("LATEST_VERSION=18-3.7\n")
    (fixture / "18-3.7").mkdir()
    dockerfile = fixture / "18-3.7/Dockerfile"
    dockerfile.write_text("FROM postgres:18\nRUN printf 'a b'\n")

    def git(*args, **env):
        return subprocess.check_output([
            "git", "-c", "commit.gpgsign=false", "-c", "core.hooksPath=/dev/null",
            "-c", "user.name=Test", "-c", "user.email=test@example.invalid", *args,
        ], cwd=fixture, env={**os.environ, **env}, text=True).strip()

    git("init", "-q")
    git("add", ".")
    git("commit", "-qm", "Initial fixture", GIT_COMMITTER_DATE="2000-01-01T00:00:00Z")
    base = git("rev-parse", "HEAD")
    timestamp = int(git("log", "-1", "--format=%ct"))
    dockerfile.write_text("FROM postgres:18\nRUN printf 'ab'\n")
    with chdir(fixture):
        assert namespace["meaningful_worktree_change"]("18-3.7/Dockerfile")
    git("commit", "-qam", "Change a quoted value", GIT_COMMITTER_DATE="2001-01-01T00:00:00Z")
    with chdir(fixture):
        assert namespace["meaningful_commit_after"](["18-3.7/Dockerfile"], timestamp)
    _, targets = select("pull_request", cwd=fixture, PR_BASE_SHA=base)
    assert targets == {("18-3.7", "default")}

    base = git("rev-parse", "HEAD")
    timestamp = int(git("log", "-1", "--format=%ct"))
    dockerfile.write_text(dockerfile.read_text() + "\n# Updated comment\n")
    with chdir(fixture):
        assert not namespace["meaningful_worktree_change"]("18-3.7/Dockerfile")
    git("commit", "-qam", "Add a comment", GIT_COMMITTER_DATE="2002-01-01T00:00:00Z")
    with chdir(fixture):
        assert not namespace["meaningful_commit_after"](["18-3.7/Dockerfile"], timestamp)
    _, targets = select("pull_request", cwd=fixture, PR_BASE_SHA=base)
    assert not targets

    base = git("rev-parse", "HEAD")
    smoke = fixture / "test/tests/postgis-basics/run.sh"
    smoke.parent.mkdir(parents=True)
    smoke.write_text("#!/bin/bash\necho smoke\n")
    git("add", ".")
    git("commit", "-qm", "Add smoke test")
    _, targets = select("pull_request", cwd=fixture, PR_BASE_SHA=base)
    assert targets == {("18-3.7", "default")}

    (fixture / "18-3.7/Dockerfile").write_text("FROM postgres:18\nARG POSTGIS_VERSION=3.7.0\n")
    release, _ = select("workflow_dispatch", cwd=fixture)
    assert not any(item["experimental"] for item in json.loads(release["images"])["include"])

print("workflow image selection checks passed")
