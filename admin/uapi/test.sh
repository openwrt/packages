#!/bin/sh

# shellcheck shell=busybox

set -e

uci get uhttpd.main.ucode_prefix | grep -F "/api/v${PKG_VERSION%%.*}=/usr/share/uapi/main.uc"

# main.uc is the uhttpd handler, which is a template, hence -T.
ucode -c -T -o /dev/null /usr/share/uapi/main.uc
for f in /usr/share/uapi/raw.uc /usr/share/uapi/lib/*.uc /usr/share/uapi/resources/*.uc; do
	ucode -c -o /dev/null "$f"
done

token="$(printf 'ci\tscopes=system:ro')"
uapi-token create --name ci --scope 'system:ro' | grep -E '^[0-9a-f]{32}$'
uapi-token list | grep -Fx "$token"
uapi-token revoke ci
! uapi-token list | grep -Fx "$token"
