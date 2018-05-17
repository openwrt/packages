# Bird6-OpenWRT Library - Functions used in /etc/init.d/bird6 script.
#
#
# Copyright (C) 2014-2017 - Eloi Carbo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


# Function: writeToConfig $1
# $1 string.
# Allows to write in the $BIRD_CONFIG file, the string $1. This function does not check the $1 string.
# Example: writeToConfig "value: $N"
writeToConfig() {
    echo "$1" >> ${BIRD_CONFIG}
}


# Function: write $1 $2
# $1 string. $2 string.
# This function checks if $2 is empty. If not, it writes the string $1 in the $BIRD_CONFIG file.
# Use write function to check if $1, value found inside $2, is not empty and can be written in the configuration file.
# Example: N=""; write "value: $N" $N;
write() {
    [ -n "$2" ] && writeToConfig "$1"
}


#Function: write_bool $1 $2
# $1 string; $2 boolean
# This function checks if $2 is true or false and write the $1 string into $BIRD_CONFIG file.
# The function writes a # before the $2 string if its false.
# Example: local N=0; write_bool $N
write_bool() {
    [ "$2" == 0 ] && writeToConfig "#   $1;" || writeToConfig "    $1;"
}


# Function: get $1 $2
# $1 string. $2 string
# This function uses the external UCI function "config_get $result $section $option" to obtain a string value from UCI config file.
# To use this function, use the same name of the UCI option for the variable.
# Example: UCI (option id 'abcd'); local id; get id $section
get() {
    config_get $1 $2 $1
}


# Function: get_bool $1 $2
# $1 boolean. $2 string
# This function uses the external UCI function "config_get_bool $result $section $option" to obtain a boolean value from UCI config file.
# To use this function, use the same name of the UCI option for the variable $1.
# Example: UCI (option use_ipv6 '1'); local use_ipv6; get use_ipv6 $section
get_bool() {
    config_get_bool $1 $2 $1
}


# Function: multipath_list $1
# $1 string
# This function writes the $1 string in the multipath routes.
multipath_list() {
    write "          via $1" $1
}


# Function: prepare_tables $1
# $1 string
# This function gets each "table" section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI table section
prepare_tables() {
    local section="$1"; local name

    get name ${section}

    write "table ${name};" ${name}
}


# Function: prepare_global $1
# $1 string
# This function gets each "global" section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI global section. prepare_global is the first configuration set in the bird6.conf and removes the old file.
prepare_global () {
    local section="$1"
    local log_file; local log; local debug; local router_id; local table
    local listen_bgp_addr; local listen_bgp_port; local listen_bgp_dual

    # Remove old configuration file
    rm -f "${BIRD_CONFIG}"

    get log_file ${section}
    get log ${section}
    get debug ${section}
    get router_id ${section}
    get table ${section}
    get listen_bgp_addr ${section}
    get listen_bgp_port ${section}
    get listen_bgp_dual ${section}

    # First line of the NEW configuration file
    echo "#Bird6 configuration using UCI:" > ${BIRD_CONFIG}
    writeToConfig " "
    #TODO: Set Syslog as receiver if empty
    #    LOGF="${log_file:-syslog]}"
    #TODO: If $log/$debug are empty, set to off
    if [ -n "${log_file}" -a -n "${log}" ]; then
        firstEntry="${log:0:3}"
        if [ "${firstEntry}" = "all" -o "${firstEntry}" = "off" ]; then
            writeToConfig 'log "'${log_file}'" '${firstEntry}';'
        else
            logEntries=$(echo ${log} | tr " " ",")
            writeToConfig "log \"${log_file}\" { ${logEntries} };"
        fi
    fi

    if [ -n "${debug}" ]; then
        firstEntry="${debug:0:3}"
        if [ "${firstEntry}" = "all" -o "${firstEntry}" = "off" ]; then
            writeToConfig "debug protocols ${firstEntry};"
        else
            debugEntries=$(echo ${debug} | tr " " ",")
            writeToConfig "debug protocols { ${debugEntries} };"
        fi
    fi
    writeToConfig " "
    writeToConfig "#Router ID"
    write "router id ${router_id};" ${router_id}
    writeToConfig " "
    writeToConfig "#Secondary tables"
    config_foreach prepare_tables 'table'
    if [ -n "${listen_bgp_dual}" -o "${listen_bgp_dual}" = "0" ]; then
        writeToConfig "listen bgp ${listen_bgp_addr} ${listen_bgp_port} v6only;"
    else
        writeToConfig "listen bgp ${listen_bgp_addr} ${listen_bgp_port} dual;"
    fi
    writeToConfig " "
}


# Function: prepare_routes $1
# $1 string
# This function gets each "route" section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI route section. Each type of route has its own treatment.
prepare_routes() {
    local instance; local prefix; local via; local type
    local section="$1"
    local protoInstance="$2"

    get instance ${section}
    get type ${section}
    get prefix ${section}
    
    if [ "${instance}" = "${protoInstance}" ]; then
        case "${type}" in
            "router")
                get via ${section}
                [ -n "${prefix}" -a -n "${via}" ] && writeToConfig "    route ${prefix} via ${via};"
                ;;
            "special")
                get attribute ${section}
                [ -n "${prefix}" -a -n "${attribute}" ] && writeToConfig "    route ${prefix} ${attribute};"
                ;;
            "iface")
                get iface ${section}
                [ -n "${prefix}" -a -n "${iface}" ] && writeToConfig '    route '${prefix}' via "'${iface}'";'
                ;;
            "multipath")
                write "    route ${prefix} multipath" ${prefix}
                config_list_foreach ${section} l_via multipath_list
                writeToConfig "        ;"
                ;;
        esac
    fi
}


# Function: prepare_kernel $1
# $1 string
# This function gets each "kernel" protocol section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI kernel section.
prepare_kernel() {
    local section="$1"
    local disabled; local table; local kernel_table; local import; local export
    local scan_time; local persist; local learn

    get_bool disabled ${section}
    get table ${section}
    get import ${section}
    get export ${section}
    get scan_time ${section}
    get kernel_table ${section}
    get learn ${section}
    get persist ${section}

    write "#${section} configuration:" ${section}
    writeToConfig "protocol kernel ${section} {" ${section}
    write_bool disabled ${disabled}
    write "    table ${table};" ${table}
    write "    kernel table ${kernel_table};" ${kernel_table}
    write_bool learn ${learn}
    write_bool persist ${persist}
    write "    scan time ${scan_time};" ${scan_time}
    write "    import ${import};" ${import}
    write "    export ${export};" ${export}
    writeToConfig "}"
    writeToConfig " "
}


# Function: prepare_static $1
# $1 string
# This function gets each "static" protocol section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI static section.
prepare_static() {
    local section="$1"
    local disabled; local table

    get disabled ${section}
    get table ${section}

    if [ "${disabled}" -eq 0 ]; then
        writeToConfig "#${section} configration:" ${section}
        writeToConfig "protocol static {"
        write "    table ${table};" ${table}
        config_foreach prepare_routes 'route' ${section}
        writeToConfig "}"
        writeToConfig " "
    fi
}


# Function: prepare_direct $1
# $1 string
# This function gets each "direct" protocol section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI direct section.
prepare_direct() {
    local section="$1"
    local disabled; local interface

    get disabled ${section}
    get interface ${section}

    write "#${section} configuration:" ${section}
    writeToConfig "protocol direct {"
    write_bool disabled ${disabled}
    write "    interface ${interface};" ${interface}
    writeToConfig "}"
    writeToConfig " "
}


# Function: prepare_pipe $1
# $1 string
# This function gets each "pipe" protocol section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI direct section.
prepare_pipe() {
    local section="$1"
    local disabled; local table; local peer_table; local mode; local import; local export

    get disabled ${section}
    get peer_table ${section}
    get mode ${section}
    get table ${section}
    get import ${section}
    get export ${section}

    write "#${section} configuration:" ${section}
    writeToConfig "protocol pipe ${section} {" ${section}
    write_bool disabled ${disabled}
    write "    table ${table};" ${table}
    write "    peer table ${peer_table};" ${peer_table}
    write "    mode ${mode};" ${mode}
    write "    import ${import};" ${import}
    write "    export ${export};" ${export}
    writeToConfig "}"
    writeToConfig " "
}


# Function: prepare_device $1
# $1 string
# This function gets each "device" protocol section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI device section.
prepare_device() {
    local section="$1"
    local disabled; local scan_time

    get disabled ${section}
    get scan_time ${section}

    write "#${section} configuration:" ${section}
    writeToConfig "protocol device {"
    write_bool disabled ${disabled}
    write "    scan time ${scan_time};" ${scan_time}
    writeToConfig "}"
    writeToConfig " "
}


# Function: prepare_bgp_template $1
# $1 string
# This function gets each "bgp_template" protocol section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI bgp_template section.
# Careful! Template options will be replaced by "instance" options if there is any match.
prepare_bgp_template() {
    local section="$1"
    local disabled; local table; local import; local export; local local_address
    local local_as; local neighbor_address; local neighbor_as; local source_address
    local next_hop_self; local next_hop_keep; local rr_client; local rr_cluster_id
    local import_limit; local import_limit_action; local export_limit; local export_limit_action
    local receive_limit; local receive_limit_action; local igp_table

    get_bool disabled ${section}
    get_bool next_hop_self ${section}
    get_bool next_hop_keep ${section}
    get table ${section}
    get import ${section}
    get export ${section}
    get local_address ${section}
    get local_as ${section}
    get igp_table ${section}
    get rr_client ${section}
    get rr_cluster_id ${section}
    get import_limit ${section}
    get import_limit_action ${section}
    get export_limit ${section}
    get export_limit_action ${section}
    get receive_limit ${section}
    get receive_limit_action ${section}
    get neighbor_address ${section}
    get neighbor_as ${section}

    writeToConfig "#${section} template:"
    writeToConfig "template bgp ${section} {"
    [ -n "${disabled}" ] && write_bool disabled ${disabled}
    write "    table ${table};" ${table}
    write "    local as ${local_as};" ${local_as}
    write "    source address ${local_address};" ${local_address}
    write "    import ${import};" ${import}
    write "    export ${export};" ${export}
    if [ -n "${next_hop_self}" ]; then
        [ "${next_hop_self}" = "1" ] && writeToConfig "    next hop self;" || writeToConfig "#    next hop self;"
    fi
    if [ -n "${next_hop_keep}" ]; then
        [ "${next_hop_keep}" = "1" ] && writeToConfig "    next hop keep;" || writeToConfig "#    next hop keep;"
    fi
    [ -n "${igp_table}" ] && writeToConfig "    igp table ${igp_table};"
    [ "${rr_client}" = "1" ] && writeToConfig "    rr client;" || writeToConfig "#    rr client;"
    write "    rr cluster id ${rr_cluster_id};" ${rr_cluster_id}
    if [ -n "${import_limit}" -a "${import_limit}" > "0" ]; then
        [ -z "${import_limit_action}" ] && ${import_limit_action} = "warn"
        writeToConfig "    import limit ${import_limit} action ${import_limit_action};"
    fi
    if [ -n "${export_limit}" -a "${export_limit}" > "0" ]; then
        [ -z "${export_limit_action}" ] && ${export_limit_action} = "warn"
        writeToConfig "    export limit ${export_limit} action ${export_limit_action};"
    fi
    if [ -n "${receive_limit}" -a "${receive_limit}" > "0" ]; then
        [ -z "${receive_limit_action}" ] && ${receive_limit_action} = "warn"
        writeToConfig "    receive limit ${receive_limit} action ${receive_limit_action};"
    fi
    [ -n "${neighbor_address}" -a -n "${neighbor_as}" ] && writeToConfig "    neighbor ${neighbor_address} as ${neighbor_as};"
    writeToConfig "}"
    writeToConfig " "
}


# Function: prepare_bgp $1
# $1 string
# This function gets each "bgp" protocol section in the UCI configuration and sets each option in the bird6.conf file.
# $1 is set as the ID of the current UCI bgp section.
# Careful! The options set in bgp instances overlap bgp_template ones.
prepare_bgp() {
    local section="$1"
    local disabled; local table; local template; local description; local import
    local export; local local_address; local local_as; local neighbor_address
    local neighbor_as; local rr_client; local rr_cluster_id; local import_limit
    local import_limit_action; local export_limit; local export_limit_action
    local receive_limit; local receive_limit_action; local igp_table

    get disabled ${section}
    get table ${section}
    get template ${section}
    get description ${section}
    get import ${section}
    get export ${section}
    get local_address ${section}
    get local_as ${section}
    get igp_table ${section}
    get rr_client ${section}
    get rr_cluster_id ${section}
    get import_limit ${section}
    get import_limit_action ${section}
    get export_limit ${section}
    get export_limit_action ${section}
    get receive_limit ${section}
    get receive_limit_action ${section}
    get neighbor_address ${section}
    get neighbor_as ${section}

    writeToConfig "#${section} configuration:"
    [ -n "${template}" ] && writeToConfig "protocol bgp ${section} from ${template} {" || writeToConfig "protocol bgp ${section} {"
    [ -n "${disabled}" ] && write_bool disabled ${disabled}
    write "    table ${table};" ${table}
    write "    local as ${local_as};" ${local_as}
    write "    source address ${local_address};" ${local_address}
    write "    import ${import};" ${import}
    write "    export ${export};" ${export}
    if [ -n "${next_hop_self}" ]; then
        [ "${next_hop_self}" = "1" ] && writeToConfig "    next hop self;" || writeToConfig "#    next hop self;"
    fi
    if [ -n "${next_hop_keep}" ]; then
        [ "${next_hop_keep}" = "1" ] && writeToConfig "    next hop keep;" || writeToConfig "#    next hop keep;"
    fi
    [ -n "${igp_table}" ] && writeToConfig "    igp table ${igp_table};"
    [ "${rr_client}" = "1" ] && writeToConfig "    rr client;" || writeToConfig "#    rr client;"
    write "    rr cluster id ${rr_cluster_id};" ${rr_cluster_id}
    if [ -n "${import_limit}" -a "${import_limit}" > "0" ]; then
        [ -z "${import_limit_action}" ] && ${import_limit_action} = "warn"
        writeToConfig "    import limit ${import_limit} action ${import_limit_action};"
    fi
    if [ -n "${export_limit}" -a "${export_limit}" > "0" ]; then
        [ -z "${export_limit_action}" ] && ${export_limit_action} = "warn"
        writeToConfig "    export limit ${export_limit} action ${export_limit_action};"
    fi
    if [ -n "${receive_limit}" -a "${receive_limit}" > "0" ]; then
        [ -z "${receive_limit_action}" ] && ${receive_limit_action} = "warn"
        writeToConfig "    receive limit ${receive_limit} action ${receive_limit_action};"
    fi
    [ -n "${neighbor_address}" -a -n "${neighbor_as}" ] && writeToConfig "    neighbor ${neighbor_address} as ${neighbor_as};"
    writeToConfig "}"
    writeToConfig " "
}


# Function: gather_filters
# This function gets all the FILES under /filters folder and adds
# them into the config as %include elements on top of the file
# If there are no filters, the section will remain empty.
gather_filters() {
    writeToConfig "#Filters Section:"
    for filter in $(find /etc/${BIRD}/filters -type f); do
        writeToConfig "include \"${filter}\";"
    done
    writeToConfig "#End of Filters --"
    writeToConfig " "
}


# Function: gather_functions
# This function gets all the FILES under /functions folder and adds
# them into the config as %include elements on top of the file
# If there are no filters, the section will remain empty.
gather_functions() {
    writeToConfig "#Functions Section:"
    for func in $(find /etc/${BIRD}/functions -type f); do
        writeToConfig "include \"${func}\";"
    done
    writeToConfig "#End of Functions --"
    writeToConfig " "
}
