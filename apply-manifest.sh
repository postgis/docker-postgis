#!/usr/bin/env bash
set -Eeuo pipefail
# Source environment variables and necessary configurations
source tools/environment_init.sh

[ -f ./versions.json ]
input_file="versions.json"
rm -f manifest.sh

cat <<'EOF' >manifest.sh
#!/usr/bin/env bash
set -Eeuo pipefail
# Source environment variables and necessary configurations
source tools/environment_init.sh

#
# Updating the docker manifest for the postgis image.
# This script uses the version.json metadata file as input to create the updated manifest.
#   manifest-tool doc : https://github.com/estesp/manifest-tool
#
# NOTE: THIS FILE IS GENERATED VIA "./apply-manifest.sh"
# PLEASE DO NOT EDIT IT DIRECTLY.
#
EOF

create_manifest() {
    local tags="$1"
    local arch="$2"

    # Split tags and arch into arrays
    IFS=' ' read -ra tag_array <<<"$tags"
    IFS=' ' read -ra arch_array <<<"$arch"

    # Check the arch parameter
    if [[ ${#arch_array[@]} -lt 1 || ${#arch_array[@]} -gt 2 ]]; then
        echo "Error: The arch parameter must have 1 or 2 elements."
        return 1
    fi

    local platform_arch=""
    for element in "${arch_array[@]}"; do
        if [ -z "$platform_arch" ]; then
            platform_arch="linux/$element"
        else
            platform_arch="$platform_arch,linux/$element"
        fi
    done

    # Create and push manifest for each tag.
    # comment: Sometimes some images is missing ( ~ synchronisation issues with CircleCI )
    #   .. and we have to continue the script, so we use the || true
    for tag in "${tag_array[@]}"; do
        echo ""
        echo "echo \"manifest: \${dockername}:${tag}\""
        echo "manifest-tool push from-args \\"
        echo "    --platforms $platform_arch \\"
        echo "    --template \${dockername}-ARCHVARIANT:${tag} \\"
        echo "    --target \${dockername}:${tag} || true"
    done
}

versions=$(jq 'keys[]' "$input_file")
for version in $versions; do
    # Remove quotes around version
    version=$(echo "$version" | tr -d '"')
    variants=$(jq ".\"$version\" | keys[]" "$input_file")
    for variant in $variants; do
        # Remove quotes around variant
        variant=$(echo "$variant" | tr -d '"')
        tags=$(jq -r ".\"$version\".\"$variant\".tags" "$input_file")
        arch=$(jq -r ".\"$version\".\"$variant\".arch" "$input_file")

        (
            echo ""
            echo "# ----- ${version}-${variant} -----"
            create_manifest "$tags" "$arch"
        ) >>manifest.sh

    done
done

echo "Done! a new ./manifest.sh has been created!"
chmod +x ./manifest.sh
head -n 50 <./manifest.sh
