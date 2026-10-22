#!/usr/bin/env python3
"""Check image defaults and smoke-test requirements without Docker."""

from pathlib import Path
import re
import subprocess


root = Path(__file__).resolve().parents[1]
example = (root / "examples/image-with-postgis-clis/Dockerfile").read_text()
assert "USER root" in example.split("RUN", 1)[0]
assert example.rstrip().endswith("USER postgres")

for dockerfile in [*root.glob("*/Dockerfile"), *root.glob("*/alpine/Dockerfile")]:
    content = dockerfile.read_text()
    kind = "alpine" if dockerfile.parent.name == "alpine" else (
        "master" if dockerfile.parent.name.endswith("-master") else (
            "source" if "AS postgis-build" in content else ""
        )
    )
    template = (root / (f"Dockerfile.{kind}.template" if kind else "Dockerfile.template")).read_text()
    pattern = ".*?".join(map(re.escape, re.split(r"%%[A-Z0-9_]+%%", template)))
    assert re.fullmatch(pattern, content, re.S), f"Regenerate {dockerfile.relative_to(root)} with update.sh"

smoke = (root / "test/tests/postgis-basics/run.sh").read_text()
requirements = smoke.split("h3_required=false\n", 1)[1].split("\ntest_h3=", 1)[0]
for image, advertised, expected in (
    ("16-master", "false", "true"),
    ("19rc1-master-alpine", "false", "false"),
    ("18-3.6", "true", "true"),
    ("18-3.6-alpine", "false", "false"),
):
    # The mock returns the package requirement advertised by the image.
    script = f'docker() {{ printf "%s" "{advertised}"; }}\nimage=postgis/postgis:{image}\nh3_required=false\n' + requirements
    result = subprocess.check_output(["bash", "-c", script + '\nprintf "%s" "$h3_required"'], text=True)
    assert result == expected, (image, result)

assert (root / "README.md").stat().st_size < 25000, "README exceeds the Docker Hub size limit"
print("image default and smoke requirement checks passed")
