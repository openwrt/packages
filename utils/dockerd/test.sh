#!/bin/sh

# shellcheck shell=busybox

init_script="${DOCKERD_INIT_SCRIPT:-/etc/init.d/dockerd}"
boot_body="$(sed -n '/^boot() {$/,/^}$/p' "${init_script}")"

echo "${boot_body}" | grep -q 'rc_procd start_service' || {
	echo "dockerd boot() does not start the service" >&2
	exit 1
}

if echo "${boot_body}" | grep -qw uciadd; then
	echo "dockerd boot() must not re-run one-time UCI initialization" >&2
	exit 1
fi

grep -q '\[ "${changed}" -eq 0 \] || reload_config' "${init_script}" || {
	echo "dockerd uciadd() must reload only after changing UCI" >&2
	exit 1
}
