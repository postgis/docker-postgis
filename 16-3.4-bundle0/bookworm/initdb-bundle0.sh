#!/bin/bash
# shellcheck disable=SC2154
set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# install pg-svg-lib
"${psql[@]}" < /pg_svg/pg-svg-lib.sql
