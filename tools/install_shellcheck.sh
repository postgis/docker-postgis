#!/bin/bash
set -Eeuo pipefail

# https://github.com/koalaman/shellcheck#installing-a-pre-compiled-binary

scversion="stable"
wget -qO- "https://github.com/koalaman/shellcheck/releases/download/${scversion?}/shellcheck-${scversion?}.linux.x86_64.tar.xz" | tar -xJv
cp "shellcheck-${scversion}/shellcheck" /usr/bin/
shellcheck --version
