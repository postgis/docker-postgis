#!/bin/bash
set -Eeuo pipefail
# Source environment variables and necessary configurations
source tools/environment_init.sh

[ -f ./versions.json ]

input_file="versions.json"
versions=$(jq 'keys[]' "$input_file")
distinct_variants=$(jq -r 'to_entries[] | .value | keys[]' "$input_file" | sort -u)

rm -f _dockerlists_*.md
for readme_group in $distinct_variants recentstack bundle test; do
    echo "init _dockerlists_${readme_group}.md"
    echo "| \`$dockername:\` tags | Dockerfile | Arch | OS | Postgres | PostGIS |" >>_dockerlists_"${readme_group}".md
    echo "| ---- | :-: | :-: | :-: | :-: | :-: |" >>_dockerlists_"${readme_group}".md
done

for version in $versions; do
    # Remove quotes around version
    version=$(echo "$version" | tr -d '"')
    variants=$(jq ".\"$version\" | keys[]" "$input_file")
    for variant in $variants; do

        variant=$(echo "$variant" | tr -d '"')
        readme_group=$(jq -r ".\"$version\".\"$variant\".readme_group" "$input_file")
        PG_DOCKER=$(jq -r ".\"$version\".\"$variant\".PG_DOCKER" "$input_file")
        POSTGIS_VERSION=$(jq -r ".\"$version\".\"$variant\".POSTGIS_VERSION" "$input_file")
        postgis=$(jq -r ".\"$version\".\"$variant\".postgis" "$input_file")
        arch=$(jq -r ".\"$version\".\"$variant\".arch" "$input_file")

        if [[ "$postgis" == "master" ]]; then
            POSTGIS_DOC_VERSION="development: postgis, geos, proj, gdal"
        elif [[ "$postgis" == "recentstack" ]]; then
            POSTGIS_DOC_VERSION="..recentstack: latest tagged postgis, geos, proj, gdal"
        else
            POSTGIS_DOC_VERSION=$(echo "$POSTGIS_VERSION" | awk -F'[+-]' '{print $1}')
        fi

        tags=$(jq -r ".\"$version\".\"$variant\".tags" "$input_file")
        tagslinks=""
        for tag in $tags; do
            tagslinks+="[\`${tag}\`](${dockerhublink}${tag}), "
        done
        # Remove trailing comma and space
        tagslinks=$(echo -n "$tagslinks" | sed 's/, *$//')

        echo "| ${tagslinks} | [Dockerfile](${githubrepolink}/${version}/${variant}/Dockerfile) | ${arch} | ${variant} | ${PG_DOCKER} | ${POSTGIS_DOC_VERSION} |" >>_dockerlists_"${readme_group}".md

    done
done

echo "|-------------------------|"
echo "|-   Generated images    -|"
echo "|-------------------------|"

for readme_group in $distinct_variants recentstack bundle test; do
    echo " "
    echo "---- ${readme_group} ----"
    cat _dockerlists_"${readme_group}".md
done

# ------------- Update README.md ------------------
# Get current date and  Replace date in README.md
TODAY=$(date +%Y-%m-%d)
sed -i -r "s/(## Versions) \([0-9]{4}-[0-9]{2}-[0-9]{2}\)/\1 ($TODAY)/g" README.md
# Replace content between the special comments in README.md for each readme_group
for readme_group in $distinct_variants recentstack bundle test; do
    echo "## ${readme_group} ##"
    awk -v readme_group="$readme_group" -v content="$(<_dockerlists_"${readme_group}".md)" '
    $0 ~ "<!-- "readme_group"_begin  -->" {print; print content; f=1; next}
    $0 ~ "<!-- "readme_group"_end  -->" {f=0}
    !f' README.md >tmp.md && mv tmp.md README.md
done

# Check README.md size; for safe uploading to the docker hub;
# https://github.com/peter-evans/dockerhub-description/issues/69
README_SIZE_LIMIT=25000
file_size=$(stat --format=%s "README.md")
echo " "
echo "README.md size is $file_size bytes ( max limit $README_SIZE_LIMIT bytes )"
if [[ $file_size -ge $README_SIZE_LIMIT ]]; then
    echo "Error: README.md is too large ($file_size bytes). "
    echo "  Must be less than $README_SIZE_LIMIT bytes!"
    echo "  The github API automatically truncates README.md files to $README_SIZE_LIMIT bytes."
    exit 1
fi

echo " "
echo "README.md updated "
echo " "
