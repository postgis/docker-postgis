# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154
testAlias[postgis/postgis]=postgres

imageTests[postgis/postgis]='
	postgis-basics
'
