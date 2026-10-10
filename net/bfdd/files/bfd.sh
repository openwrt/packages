#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
    . /lib/functions.sh
    . ../netifd-proto.sh
    init_proto "$@"
}

proto_bfd_init_config() {
    proto_config_add_string peer_address
    proto_config_add_string local_address
    proto_config_add_boolean multihop

    #proto_config_add_int vxlan # not actually implemented in bfdd, it only has a stub
    proto_config_add_string vrf_name

    proto_config_add_int detect_multiplier
    proto_config_add_int receive_interval
    proto_config_add_int transmit_interval

    proto_config_add_boolean echo_mode
    proto_config_add_int echo_interval
}

# TODO: see if implementing proto_bfd_restart would let us update bfd peer in place
# in case only mutable parameters have changed

proto_bfd_setup() {
    local config="$1"
    local iface="$2"

    # immutable parameters (key)
    local         peer_address local_address multihop vrf_name
    json_get_vars peer_address local_address multihop vrf_name
    # mutable parameters (non-key)
    local         detect_multiplier receive_interval transmit_interval echo_mode echo_interval
    json_get_vars detect_multiplier receive_interval transmit_interval echo_mode echo_interval

    if ! pidof bfdd; then
        service bfdd start
    fi

    local arg_mhop=""
    if [ "$multihop" = "1" ]; then
        arg_mhop="-m"
    fi

    json_init
    json_add_string "label" "$config"

    [ -z "$vrf_name" ] || json_add_string "vrf-name" "$vrf_name"

    # note: for intervals, not adding the key to JSON is different than passing an empty string
    # key missing = use daemon's default
    # empty string = zero
    # when a user does not set a setting, we want the daemon's default

    [ -z "$detect_multiplier" ] || json_add_string "detect-multiplier" "$detect_multiplier"
    [ -z "$receive_interval" ]  || json_add_string "receive-interval" "$receive_interval"
    [ -z "$transmit_interval" ] || json_add_string "transmit-interval" "$transmit_interval"
    [ -z "$echo_interval" ]     || json_add_string "echo-interval" "$echo_interval"

    json_add_boolean "echo-mode" "$echo_mode"

    proto_export "BFD_CONFIG=$config"
    proto_run_command "$config"  bfdctl -a $arg_mhop \
        -i "$iface" -p "$peer_address" ${local_address:+-l "$local_address"} \
        -j "$(json_dump)" \
        -M -E /lib/netifd/bfd-event
}

proto_bfd_teardown() {
    local config="$1"

    # first kill the bfdctl -M that listens for events,
    # since it holds refcount on the bfd session, preventing it from being deleted
    proto_kill_command "$config"
    # then remove the session
    bfdctl -d -L "$config"
}

[ -n "$INCLUDE_ONLY" ] || {
    add_protocol bfd
}
