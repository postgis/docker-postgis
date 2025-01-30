#!/usr/bin/env bash
set -Eeuo pipefail
# Source environment variables and necessary configurations
source tools/environment_init.sh

# This code derived from:
#   - URL: https://github.com/docker-library/postgres/blob/master/apply-templates.sh
#   - Copyright: (c) Docker PostgreSQL Authors
#   - MIT License, https://github.com/docker-library/postgres/blob/master/LICENSE

# Check dependencies
[ -f ./versions.json ]

jqt='.jq-template.awk'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
    jqt="$BASHBREW_SCRIPTS/jq-template.awk"
elif [ "${BASH_SOURCE[0]}" -nt "$jqt" ]; then
    # https://github.com/docker-library/bashbrew/blob/master/scripts/jq-template.awk
    wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/9f6a35772ac863a0241f147c820354e4008edf38/scripts/jq-template.awk'
fi

jqf='.template-helper-functions.jq'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
    jqf="$BASHBREW_SCRIPTS/template-helper-functions.jq"
elif [ "${BASH_SOURCE[0]}" -nt "$jqf" ]; then
    wget -qO "$jqf" 'https://github.com/docker-library/bashbrew/raw/master/scripts/template-helper-functions.jq'
fi

if [ "$#" -eq 0 ]; then
    versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
    eval "set -- $versions"
fi

echo "versions = $versions"

generated_warning() {
    cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "./tools/apply-templates.sh"
		#       source: "$1"
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#
	EOH
}

for version; do
    export version

    bundleType="$(echo "$version" | cut -d '-' -f 3)"
    variants="$(jq -r '.[env.version]| keys | map(@sh) | join(" ")' versions.json)"
    eval "variants=( $variants )"

    for variant in "${variants[@]}"; do
        export variant

        dir="$version/$variant"
        echo "processing $dir ..."

        template=./templates/"$(jq -r '.[env.version][env.variant].template' versions.json)"
        echo "  template=$template"

        initfile=./templates/"$(jq -r '.[env.version][env.variant].initfile' versions.json)"
        echo "  initfile=$initfile"

        tags="$(jq -r '.[env.version][env.variant].tags' versions.json)"
        echo "  tags=$tags"

        cp -a "$initfile" "$dir/"
        if [ -z "$bundleType" ]; then
            cp -a ./templates/update-postgis.sh "$dir/"
        fi

        echo "$tags" >"$dir/tags"

        {
            generated_warning "$template"
            gawk -f "$jqt" "$template"
        } >"$dir/Dockerfile"

    done
done

echo " "
echo " ./tools/apply-template : done"
echo " "
