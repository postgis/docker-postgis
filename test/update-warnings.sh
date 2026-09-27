#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2016,SC2034,SC2154,SC2329
set -Eeuo pipefail

if (( BASH_VERSINFO[0] < 4 )); then
    echo "update-warnings.sh requires Bash 4 or newer" >&2
    exit 2
fi

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
update_sh="$repo/update.sh"
cd "$repo"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    [[ "$expected" == "$actual" ]] || fail "$message (expected '$expected', got '$actual')"
}

assert_contains() {
    local value="$1"
    local needle="$2"
    local message="$3"
    [[ "$value" == *"$needle"* ]] || fail "$message (missing '$needle')"
}

assert_not_contains() {
    local value="$1"
    local needle="$2"
    local message="$3"
    [[ "$value" != *"$needle"* ]] || fail "$message (unexpected '$needle')"
}

read_block() {
    local start="$1"
    local end="$2"
    local include_end="${3:-true}"

    awk -v start="$start" -v end="$end" -v include_end="$include_end" '
        $0 == start { copying = 1 }
        copying && $0 == end && include_end != "true" { exit }
        copying { print }
        copying && $0 == end { exit }
    ' "$update_sh"
}

source_block() {
    source <(read_block "$1" "$2" "${3:-true}")
}

warnings=()
warning() {
    warnings+=("$*")
    echo "WARNING: $*" >&2
}

matrixVersions=(14-3.6 14-3.7 19rc1-3.7)
officialPostgresLibrary=$'Tags: 13, 14\nArchitectures: amd64, arm64v8\nDirectory: 14/alpine3.24\n\nTags: 19, 19rc1-alpine, 19-alpine\nArchitectures: amd64, arm64v8\nDirectory: 19/alpine3.24\n'
officialPostgresReleaseTags=$'13\n14\n19'
source_block 'declare -A knownPostgresTags=()' '# Select numeric release tags only; branches and prereleases are not stable releases.' false
postgresWarnings="${warnings[*]}"
assert_contains "$postgresWarnings" '19' 'stable PostgreSQL promotion warning'
assert_not_contains "$postgresWarnings" '13' 'represented PostgreSQL release warning'
assert_not_contains "$postgresWarnings" '14' 'represented PostgreSQL release warning'

source_block 'stable_git_tag() {' '}'
source_block 'stable_git_hash() {' '}'
git_ls_remote() {
    if [ "$1" = --tags ]; then
        printf '%s\n' 'a refs/tags/v6.2' 'b refs/tags/v6.2.1' 'c refs/tags/v6.3-beta1' 'd refs/tags/v6.3.0rc1'
    else
        printf '%s\n' 'tag-object refs/tags/v6.2.1' 'source-commit refs/tags/v6.2.1^{}'
    fi
}
assert_equal v6.2.1 "$(stable_git_tag example)" 'stable dependency tag selection'
assert_equal source-commit "$(stable_git_hash example)" 'annotated release tag dereference'
git_ls_remote() { printf '%s\n' 'a refs/tags/3.15.0' 'b refs/tags/3.16.0beta1'; }
assert_equal 3.15.0 "$(stable_git_tag example)" 'release tags without a v prefix'
git_ls_remote() { printf '%s\n' 'a refs/tags/3.15.0'; return 1; }
if stable_git_tag example >/dev/null 2>&1; then fail 'partial release metadata must fail'; fi
if stable_git_hash example v6.2.1 >/dev/null 2>&1; then fail 'partial release commit metadata must fail'; fi
git_ls_remote() { :; }
if stable_git_hash example >/dev/null 2>&1; then fail 'missing release tags must fail'; fi
if stable_git_hash example v6.2.1 >/dev/null 2>&1; then fail 'missing release commits must fail'; fi
source_block 'function fetch_postgis_versions() {' '}'
git_ls_remote() { printf '%s\n' 'a refs/tags/3.6.4' 'b refs/tags/3.7.0rc2'; }
fetch_postgis_versions
assert_equal $'3.6.4\n3.7.0rc2' "$postgis_all_v3_versions" 'PostGIS release discovery without the REST API'
git_ls_remote() { return 1; }
if fetch_postgis_versions; then fail 'failed PostGIS tag lookup must fail'; fi
unset -f git_ls_remote

warnings=()
knownPostgisSeries=(3.6 3.7)
warnedPostgisSeries=()
maxKnownPostgisMinor=7
source_block 'function version_reverse_sort() {' '}'
source_block 'function select_postgis_source_version() {' '}'
postgis_all_v3_versions=$'3.8.0rc1\n3.8.0beta1\n3.7.0\n3.7.0rc2\n3.7.0rc1'
assert_equal 3.6.4 "$(postgis_all_v3_versions=$'3.6.4\n3.6.3\n3.6.4rc1'; select_postgis_source_version 3.6)" 'stable PostGIS source selection'
assert_equal 3.7.0rc2 "$(postgis_all_v3_versions=$'3.7.0rc2\n3.7.0rc1'; select_postgis_source_version 3.7)" 'PostGIS prerelease source selection when no stable release exists'
officialPostgisReleaseTags=$'3.8.0rc1\n3.8.0beta1\n3.7.0'
source_block 'for upstreamPostgisTag in $officialPostgisReleaseTags; do' 'declare -A alpineSuiteByPostgresTag=()' false
postgisWarnings="${warnings[*]}"
assert_contains "$postgisWarnings" '3.8' 'new PostGIS series warning'
assert_contains "$postgisWarnings" '3.7.0' 'stable PostGIS promotion warning'

warnings=()
defaultAlpineSuite=3.24
source_block 'declare -A alpineSuiteByPostgresTag=()' '#-------------------------------------------' false
assert_equal 3.24 "$(alpine_suite_for 19)" 'complete multi-platform Alpine metadata'
officialPostgresLibrary=$'Tags: 15-alpine\nArchitectures: amd64\nDirectory: 15/alpine3.25\n'
fallback_output="$(alpine_suite_for 15 2>&1)"
assert_contains "$fallback_output" '3.24' 'incomplete Alpine metadata fallback'
assert_contains "$fallback_output" 'no official Alpine image' 'Alpine fallback warning'

source_block 'function package_version() {' '}'
debianPackages=$'Package: postgresql-14\nVersion: 14.20-1.pgdg12+1\n\nPackage: postgresql-14-postgis-3\nVersion: 3.5.7+dfsg-1.pgdg12+1\n\nPackage: postgresql-14-h3\nVersion: 4.2.3-5.pgdg12+2\n\nPackage: postgresql-14-pgrouting\nVersion: 4.0.2-1.pgdg12+1\n\nPackage: postgresql-19-h3\nVersion: 4.2.3-5.pgdg12+2\n'
assert_equal '14.20-1.pgdg12+1' "$(printf '%s\n' "$debianPackages" | package_version postgresql-14)" 'PostgreSQL package lookup'
assert_equal '3.5.7+dfsg-1.pgdg12+1' "$(printf '%s\n' "$debianPackages" | package_version postgresql-14-postgis-3)" 'PostGIS package lookup'
assert_equal '4.2.3-5.pgdg12+2' "$(printf '%s\n' "$debianPackages" | package_version postgresql-14-h3)" 'H3 package lookup'
assert_equal '4.0.2-1.pgdg12+1' "$(printf '%s\n' "$debianPackages" | package_version postgresql-14-pgrouting)" 'pgRouting package lookup'
assert_equal '4.2.3-5.pgdg12+2' "$(printf '%s\n' "$debianPackages" | package_version postgresql-19-h3)" 'PG19 H3 package lookup'
assert_equal '' "$(printf '%s\n' "$debianPackages" | package_version postgresql-20-h3)" 'missing H3 package lookup'
assert_equal '' "$(printf '%s\n' "$debianPackages" | package_version postgresql-14-postgis-4)" 'missing PostGIS package lookup'
mapping_source="$(read_block "defaultAlpineSuite='3.24'" "packagesBase='https://apt.postgresql.org/pub/repos/apt/dists/'" false)"
eval "$mapping_source"
assert_contains "$mapping_source" "[14]='trixie'" 'Debian suite mapping'
assert_contains "$mapping_source" "[17]='trixie'" 'Debian suite mapping'
assert_contains "$mapping_source" "[18]='trixie'" 'Debian suite mapping'
assert_contains "$mapping_source" "[19]='trixie'" 'Debian suite mapping'
assert_contains "$mapping_source" "[3.6]='3'" 'PostGIS package suffix mapping'
assert_contains "$mapping_source" "[3.7]='3'" 'PostGIS package suffix mapping'
for old_series in 3.0 3.1 3.2 3.3 3.4 3.5; do
    assert_not_contains "$mapping_source" "[$old_series]=" 'unused pre-3.6 PostGIS package mappings'
done
assert_not_contains "$mapping_source" 'defaultDebianSuite' 'Debian suite mapping must fail closed'
source_block 'declare -A suitePackageList=()' 'for version in "${versions[@]}"; do' false
for postgres_tag in 19beta4 19rc1; do
    needs_postgis_source_build 3.6 3.6.4 "$postgres_tag" || fail 'PostgreSQL prereleases need a matching source build'
done
needs_postgis_source_build 3.7 '' 18 || fail 'missing PostGIS packages need a source build'
! needs_postgis_source_build 3.6 3.6.4 18 || fail 'stable PostgreSQL can use matching packages'
! needs_postgis_source_build master master 19rc1 || fail 'development images use their own template'
if select_debian_suite 20 3.6 >/dev/null 2>&1; then
    fail 'unknown PostgreSQL major must not select a Debian suite'
fi
if select_debian_suite 14 3.5 >/dev/null 2>&1; then
    fail 'retired PostGIS series must not select packages'
fi
for retired_suite in bookworm bullseye unknown; do
    debianSuite[14]="$retired_suite"
    if select_debian_suite 14 3.6 >/dev/null 2>&1; then fail 'retired Debian suites must be rejected'; fi
    if set_debian_dependencies "$retired_suite" >/dev/null 2>&1; then fail 'retired runtime dependencies must be rejected'; fi
done
debianSuite[14]=trixie
set_debian_dependencies trixie
assert_equal libcurl3t64-gnutls "$curlRuntimePackage" 'Trixie curl runtime package'
assert_equal libhdf5-310 "$hdf5RuntimePackage" 'Trixie HDF5 runtime package'
assert_equal libsfcgal2 "$sfcgalRuntimePackage" 'Trixie SFCGAL runtime package'
if set_debian_dependencies unknown >/dev/null 2>&1; then
    fail 'unknown Debian suite must not silently select runtime package names'
fi

mockSuiteMode=preferred
load_suite_package_metadata() {
    local postgresMajor="$2"
    versionListAmd64="$(printf 'Package: postgresql-%s\nVersion: %s.22-1.pgdg13+1\n\nPackage: postgresql-%s-postgis-3\nVersion: 3.6.4+dfsg-1.pgdg13+1\n' "$postgresMajor" "$postgresMajor" "$postgresMajor")"
    versionListArm64="$versionListAmd64"
    if [ "$mockSuiteMode" = wrong_series ]; then
        versionListAmd64="$(printf 'Package: postgresql-%s\nVersion: %s.22-1.pgdg13+1\n\nPackage: postgresql-%s-postgis-3\nVersion: 3.5.7+dfsg-1.pgdg13+1\n' "$postgresMajor" "$postgresMajor" "$postgresMajor")"
        versionListArm64="$versionListAmd64"
    elif [ "$mockSuiteMode" = no_postgis ]; then
        versionListAmd64="$(printf 'Package: postgresql-%s\nVersion: %s.22-1.pgdg13+1\n' "$postgresMajor" "$postgresMajor")"
        versionListArm64="$versionListAmd64"
    elif [ "$mockSuiteMode" = no_server ]; then
        versionListAmd64=''
        versionListArm64=''
    elif [ "$mockSuiteMode" = arch_mismatch ]; then
        versionListArm64="$(printf 'Package: postgresql-%s\nVersion: %s.22-1.pgdg13+1\n\nPackage: postgresql-%s-postgis-3\nVersion: 3.6.5+dfsg-1.pgdg13+1\n' "$postgresMajor" "$postgresMajor" "$postgresMajor")"
    fi
}

mockSuiteMode=preferred
selectedSuite=''
select_debian_suite 14 3.6
assert_equal trixie "$selectedSuite" 'preferred suite with matching PostGIS package'
mockSuiteMode=wrong_series
selectedSuite=''
select_debian_suite 14 3.6
assert_equal trixie "$selectedSuite" 'missing PostGIS series must stay on Trixie for a source build'
mockSuiteMode=no_postgis
selectedSuite=''
select_debian_suite 14 3.6
assert_equal trixie "$selectedSuite" 'Trixie source fallback when no PGDG suite has PostGIS 3.6'
mockSuiteMode=preferred
select_debian_suite 18 master
assert_equal trixie "$selectedSuite" 'development images use Trixie'
mockSuiteMode=no_server
if select_debian_suite 18 master >/dev/null 2>&1; then fail 'missing server packages must fail'; fi
mockSuiteMode=arch_mismatch
selectedSuite=''
if select_debian_suite 14 3.6 >/dev/null 2>&1; then
    fail 'architecture-mismatched PostGIS package metadata must fail'
fi

assert_contains "$(cat "$update_sh")" 'README unchanged for selected versions.' 'partial updates must leave the README alone'
assert_contains "$(cat "$update_sh")" 'dockerlistsDir="$(mktemp -d)"' 'partial update list fragments must be isolated'
assert_contains "$(cat "$update_sh")" 'if [ "$fullMatrixUpdate" = true ]; then' 'README generation must require a full update'
assert_contains "$(cat "$update_sh")" '1.83.0t64' 'Trixie Boost Chrono version'
assert_contains "$(cat "$update_sh")" 'Dockerfile.source.template' 'Debian source fallback template'
assert_contains "$(cat "$update_sh")" 'nlohmannJsonVersion=' 'nlohmann/json source discovery'
assert_contains "$(cat "$update_sh")" 'pgroutingLatestVersion=' 'pgRouting source discovery'
assert_contains "$(cat "$update_sh")" 'pgrouting-version.txt' 'pgRouting version substitution'
pgroutingTags=$'v4.1.0rc1\nref v4.0.2\nref v4.0.1\nv4.0.0'
assert_equal '4.0.2' "$(printf '%s\n' "$pgroutingTags" | sed -n 's#.*v\([0-9][0-9.]*\)$#\1#p' | sort -V | tail -n 1)" 'stable pgRouting release selection'
assert_contains "$(cat "$repo/Dockerfile.alpine.template")" '%%TIGER_GEOCODER_VERSION%%' 'Alpine Tiger version placeholder'
assert_contains "$(cat "$repo/Dockerfile.alpine.template")" 'if [ "$postgis_minor" -ge 7 ]; then' '3.7 address standardizer build supports PostgreSQL 14 and 15'
assert_contains "$(cat "$repo/Dockerfile.alpine.template")" 'if [ "$postgis_minor" -ge 7 ] && [ "$PG_MAJOR" -ge 16 ]; then' 'standalone Tiger build requires PostgreSQL 16'
assert_contains "$(cat "$repo/update-postgis.sh")" 'pg_extension_update_paths' 'separate extension upgrade path checks'
assert_contains "$(cat "$repo/update-postgis.sh")" 'address_standardizer_data_us' 'standalone address standardizer upgrade'
assert_contains "$(cat "$repo/update-postgis.sh")" 'postgis_extensions_upgrade' 'PostGIS-managed extension upgrade'
assert_contains "$(cat "$repo/update-postgis.sh")" 'postgis_tiger_geocoder' 'standalone Tiger upgrade path'
assert_contains "$(cat "$repo/update-postgis.sh")" "WHERE source::text = 'ANY' AND target::text = target_version" 'Tiger ANY upgrade fallback'

fetch_output=""
fetch_rc=0
if fetch_output="$(
    curl_download() { return 1; }
    warning() { echo "WARNING: $*" >&2; }
    source <(read_block "officialPostgresLibraryUrl='https://raw.githubusercontent.com/docker-library/official-images/master/library/postgres'" 'fi') 2>&1
)" 2>&1; then
    fetch_rc=0
else
    fetch_rc=$?
fi
assert_equal 1 "$fetch_rc" 'metadata fetch failure status'
assert_contains "$fetch_output" 'Alpine suite discovery is unavailable' 'metadata fetch warning'

echo 'synthetic update warning/package checks passed'
