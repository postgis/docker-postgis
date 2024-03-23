#!/bin/bash
set -Eeuo pipefail

# Get changed versions from git diff
#   used by auto update CI :  .github/workflows/update.yml

# example outputs: DUCKDB:v0.10.1,MOBILITYDB:v1.1.0

git diff versions.json |
    grep "^+" |
    sed 's/^+//' |
    grep -E "_CHECKOUT|_VERSION" |
    grep -vE "_SHA1" |
    sed 's/_CHECKOUT"//g;s/_VERSION"//g' |
    sed 's# "tags/##g' |
    sed 's#"##g' |
    sed 's# ##g' |
    sed 's#,##g' |
    sort | uniq |
    awk 'BEGIN { ORS=""; print ""; total_length=0; } { word_length=length($0)+1; if (total_length+word_length<=80) { print (NR>1?",":"") $0; total_length+=word_length; } else { exit; } }'
