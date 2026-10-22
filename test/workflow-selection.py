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
assert push["latest_version"] == "18-3.6"
assert targets and all(version.endswith("-master") for version, _ in targets)

dispatch, targets = select("workflow_dispatch")
assert {("19rc1-3.6", "default"), ("19rc1-3.7", "alpine")} <= targets
experimental = {(item["version"], item["variant"]): item["experimental"] for item in json.loads(dispatch["images"])["include"]}
assert not experimental["18-3.6", "default"] and not experimental["18-3.6", "alpine"]
assert all(experimental[target] for target in (("16-master", "default"), ("19rc1-3.6", "default"), ("18-3.7", "default"), ("18-3.7", "alpine")))

legacy = (root / ".github/workflows/main.yml").read_text()
matrix = legacy.split("      matrix:\n", 1)[1].split("\n    name:", 1)[0]
def values(key):
    return {value.strip(" '\"") for value in re.search(rf"(?m)^        {key}: \[(.*)\]", matrix)[1].split(",")}
assert values("postgres") == {"14", "15", "16", "17", "18", "19rc1"}
assert values("variant") == {"default", "alpine"}
rows = [{key: value.strip("'\"") for key, value in
         (line.strip().split(": ", 1) for line in block.strip().splitlines())}
        for block in matrix.split("        include:\n", 1)[1].split("          - ")[1:]]
assert {row["version"] for row in rows if "version" in row} == {"18-3.7", "19rc1-3.7"}
for row in rows:
    version = row.get("version", f"{row['postgres']}-{row['postgis']}")
    variant = row["variant"]
    assert (root / version / ("alpine/" if variant == "alpine" else "") / "Dockerfile").is_file()

verifier = workflow.split("\n  verify-build:\n", 1)[1].split("\n  publish:\n", 1)[0]
verifier = textwrap.dedent(verifier.split("          python3 - <<'PY' >> \"$GITHUB_OUTPUT\"\n", 1)[1].split("\n          PY", 1)[0])
with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    stable = {"version": "18-3.6", "variant": "default", "experimental": False}
    preview = {"version": "19rc1-3.6", "variant": "default", "experimental": True}
    def evidence(image, arch):
        path = fixture / f"evidence/postgis-evidence-{image['version']}-default-{arch}/image.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"tag": f"postgis/postgis:{image['version']}", "platform": ["linux", arch],
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
    (fixture / "Makefile").write_text("LATEST_VERSION=18-3.6\n")
    (fixture / "18-3.6").mkdir()
    dockerfile = fixture / "18-3.6/Dockerfile"
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
        assert namespace["meaningful_worktree_change"]("18-3.6/Dockerfile")
    git("commit", "-qam", "Change a quoted value", GIT_COMMITTER_DATE="2001-01-01T00:00:00Z")
    with chdir(fixture):
        assert namespace["meaningful_commit_after"](["18-3.6/Dockerfile"], timestamp)
    _, targets = select("pull_request", cwd=fixture, PR_BASE_SHA=base)
    assert targets == {("18-3.6", "default")}

    base = git("rev-parse", "HEAD")
    timestamp = int(git("log", "-1", "--format=%ct"))
    dockerfile.write_text(dockerfile.read_text() + "\n# Updated comment\n")
    with chdir(fixture):
        assert not namespace["meaningful_worktree_change"]("18-3.6/Dockerfile")
    git("commit", "-qam", "Add a comment", GIT_COMMITTER_DATE="2002-01-01T00:00:00Z")
    with chdir(fixture):
        assert not namespace["meaningful_commit_after"](["18-3.6/Dockerfile"], timestamp)
    _, targets = select("pull_request", cwd=fixture, PR_BASE_SHA=base)
    assert not targets

    (fixture / "18-3.7").mkdir()
    (fixture / "18-3.7/Dockerfile").write_text("FROM postgres:18\nARG POSTGIS_VERSION=3.7.0\n")
    release, _ = select("workflow_dispatch", cwd=fixture)
    assert not any(item["experimental"] for item in json.loads(release["images"])["include"])

print("workflow image selection checks passed")
