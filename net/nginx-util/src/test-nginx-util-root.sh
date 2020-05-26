#!/bin/sh

PRINT_PASSED=2

NGINX_UTIL="/usr/bin/nginx-util"

__esc_newlines() {
    echo "${1}" | sed -E 's/$/\\n/' | tr -d '\n' | sed -E 's/\\n$/\n/'
}

__esc_sed_rhs() {
    __esc_newlines "${1}" |  sed -E 's/[&/\]/\\&/g'
}

_sed_rhs() {
    __esc_sed_rhs "$(echo "${1}" | sed -E "s/[$]/$(__esc_sed_rhs "${2}")/g")"
}

__esc_regex() {
    __esc_newlines "${1}" | sed -E 's/[^^_a-zA-Z0-9-]/[&]/g; s/\^/\\^/g'
}

_regex() {
    __esc_regex "${1}" | sed -E -e 's/^(\[\s])*/^\\s*/' \
        -e 's/(\[\s])+\[[*]]/(\\s.*)?/g' \
        -e 's/(\[\s])+/\\s+/g' \
        -e 's/(\[\s])*\[[;]]/\\s*;/g' \
        -e "s/\[['\"]]/['\"]?/g" \
        -e "s/\[[$]]/$(__esc_sed_rhs "$(__esc_regex "${2}")")/g"
}

_echo_sed() {
    echo "" | sed -E "c${1}"
}

setpoint_add_ssl() {
    local indent="\n$1"
    local name="$2"
    local default=""
    [ "${name}" = "${LAN_NAME}" ] && default=".default"
    local prefix="${CONF_DIR}${name}"

    local CONF="$(grep -vE "$(_regex "${NGX_INCLUDE}" \
        "${LAN_LISTEN}${default}")" "${prefix}.sans" 2>/dev/null)"
    local ADDS=""
    echo "${CONF}" \
        | grep -qE "$(_regex "${NGX_INCLUDE}" "${LAN_SSL_LISTEN}${default}")" \
    || ADDS="${ADDS}${indent}$(_sed_rhs "${NGX_INCLUDE}" \
        "${LAN_SSL_LISTEN}${default}")"
    echo "${CONF}" | grep -qE "$(_regex "${NGX_SSL_CRT}" "${prefix}")" \
    || ADDS="${ADDS}${indent}$(_sed_rhs "${NGX_SSL_CRT}" "${prefix}")"
    echo "${CONF}" | grep -qE "$(_regex "${NGX_SSL_KEY}" "${prefix}")" \
    || ADDS="${ADDS}${indent}$(_sed_rhs "${NGX_SSL_KEY}" "${prefix}")"
    echo "${CONF}" | grep -qE "^\s*ssl_session_cache\s" \
    || ADDS="${ADDS}${indent}$(_sed_rhs "${NGX_SSL_SESSION_CACHE}" "${name}")"
    echo "${CONF}" | grep -qE "^\s*ssl_session_timeout\s" \
    || ADDS="${ADDS}${indent}$(_sed_rhs "${NGX_SSL_SESSION_TIMEOUT}" "")"

    if [ -n "${ADDS}" ]
    then
        ADDS="$(echo "${ADDS}" | sed -E 's/^\\n//')"
        echo "${CONF}" | grep -qE "$(_regex "${NGX_SERVER_NAME}" "${name}")" \
        && echo "${CONF}" \
            | sed -E "/$(_regex "${NGX_SERVER_NAME}" "${name}")/a\\${ADDS}" \
            > "${prefix}.with" \
        && _echo_sed "Added directives to ${prefix}.with:\n${ADDS}" \
        && return 0 \
        || _echo_sed "Cannot add directives to ${prefix}.sans, missing:\
            \n$(_sed_rhs "${NGX_SERVER_NAME}" "${name}")\n${ADDS}"
        return 1
    fi
    return 0
}

# ----------------------------------------------------------------------------

test_setpoint() {
    [ "$(cat "$1")" = "$2" ] && return
    echo "$1:"; cat "$1"
    echo "differs from setpoint:"; echo "$2"
    [ "${PRINT_PASSED}" -gt 1 ] && pst_exit 1
}


test() {
    eval "$1 2>/dev/null >/dev/null"
    if [ "$?" -eq "$2" ]
    then
        [ "${PRINT_PASSED}" -gt 0 ] \
        && printf "%-72s%-1s\n" "$1" "2>/dev/null >/dev/null (-> $2?) passed."
    else
        printf "%-72s%-1s\n" "$1" "2>/dev/null >/dev/null (-> $2?) failed!!!"
        [ "${PRINT_PASSED}" -gt 1 ] && exit 1
    fi
}


[ "$PRINT_PASSED" -gt 0 ] && printf "\nTesting %s get_env ...\n" "${NGINX_UTIL}"

eval $("${NGINX_UTIL}" get_env)
test '[ -n "${NGINX_CONF}" ]' 0
test '[ -n "${CONF_DIR}" ]' 0
test '[ -n "${LAN_NAME}" ]' 0
test '[ -n "${LAN_LISTEN}" ]' 0
test '[ -n "${LAN_SSL_LISTEN}" ]' 0
test '[ -n "${SSL_SESSION_CACHE_ARG}" ]' 0
test '[ -n "${SSL_SESSION_TIMEOUT_ARG}" ]' 0
test '[ -n "${ADD_SSL_FCT}" ]' 0


[ "$PRINT_PASSED" -gt 0 ] && printf "\nPrepare files in %s ...\n" "${CONF_DIR}"

mkdir -p "${CONF_DIR}"

cd "${CONF_DIR}" || exit 2

NGX_INCLUDE="include '\$';"
NGX_SERVER_NAME="server_name * '\$' *;"
NGX_SSL_CRT="ssl_certificate '\$.crt';"
NGX_SSL_KEY="ssl_certificate_key '\$.key';"
NGX_SSL_SESSION_CACHE="ssl_session_cache '$(echo "${SSL_SESSION_CACHE_ARG}" \
    | sed -E "s/$(__esc_regex "${LAN_NAME}")/\$/")';"
NGX_SSL_SESSION_TIMEOUT="ssl_session_timeout '${SSL_SESSION_TIMEOUT_ARG}';"

cat > "${LAN_NAME}.sans" <<EOF
# default_server for the LAN addresses getting the IPs by:
# ifstatus lan | jsonfilter -e '@["ipv4-address","ipv6-address"].*.address'
server {
    include '${LAN_LISTEN}.default';
    server_name ${LAN_NAME};
    include conf.d/*.locations;
}
EOF
CONFS="${CONFS} ${LAN_NAME}:0"

cat > minimal.sans <<EOF
server {
    server_name minimal;
}
EOF
CONFS="${CONFS} minimal:0"

cat > normal.sans <<EOF
server {
    include '${LAN_LISTEN}';
    server_name normal;
}
EOF
CONFS="${CONFS} normal:0"

cat > more_server.sans <<EOF
server {
    # include '${LAN_LISTEN}';
    server_name normal;
}
server {
    include '${LAN_LISTEN}';
    server_name more_server;
}
EOF
CONFS="${CONFS} more_server:0"

cat > more_names.sans <<EOF
server {
    include '${LAN_LISTEN}';
    server_name example.com more_names example.org;
}
EOF
CONFS="${CONFS} more_names:0"

cat > different_name.sans <<EOF
server {
    include '${LAN_LISTEN}';
    server_name minimal;
}
EOF
CONFS="${CONFS} different_name:1"

cat > comments.sans <<EOF
server { # comment1
    # comment2
    include '${LAN_LISTEN}';
    server_name comments;
    # comment3
} # comment4
EOF
CONFS="${CONFS} comments:0"

cat > name_comment.sans <<EOF
server {
    include '${LAN_LISTEN}';
    server_name name_comment; # comment
}
EOF
CONFS="${CONFS} name_comment:0"

cat > tab.sans <<EOF
server {
	include '${LAN_LISTEN}';
	server_name tab;
}
EOF
CONFS="${CONFS} tab:0"


[ "$PRINT_PASSED" -gt 0 ] && printf "\nTesting %s init_lan ...\n" "${NGINX_UTIL}"

mkdir -p "$(dirname "${LAN_LISTEN}")"

cp "${LAN_NAME}.sans" "${LAN_NAME}.conf"

test '"${NGINX_UTIL}" init_lan' 0


[ "$PRINT_PASSED" -gt 0 ] && printf "\nSetup files in %s ...\n" "${CONF_DIR}"

for conf in ${CONFS}
do test 'setpoint_add_ssl "    " '"${conf%:*}" "${conf#*:}"
done

test 'setpoint_add_ssl "\t" tab' 0 # fixes wrong indentation.


[ "$PRINT_PASSED" -gt 0 ] && printf "\nTesting %s add_ssl ...\n" "${NGINX_UTIL}"

cp different_name.sans different_name.with

test '[ "${ADD_SSL_FCT}" = "add_ssl" ] ' 0

for conf in ${CONFS}; do
    name="${conf%:*}"
    cp "${name}.sans" "${name}.conf"
    test '"${NGINX_UTIL}" add_ssl '"${name}" "${conf#*:}"
    test_setpoint "${name}.conf" "$(cat "${name}.with")"
done

[ "$PRINT_PASSED" -gt 0 ] && printf "\nTesting %s del_ssl ...\n" "${NGINX_UTIL}"

sed -i "/server {/a\\    include '${LAN_LISTEN}';" minimal.sans

for conf in ${CONFS}; do
    name="${conf%:*}"
    cp "${name}.with" "${name}.conf"
    test '"${NGINX_UTIL}" del_ssl '"${name}" "${conf#*:}"
    test_setpoint "${name}.conf" "$(cat "${name}.sans")"
done
