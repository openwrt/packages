
[ -f /usr/share/libubox/jshn.sh ] && . /usr/share/libubox/jshn.sh

uciopts="
allowroot:AllowRoot
buffersend:BufferSend
buffersize:BufferSize
configfrequency:ConfigFrequency
datasenderfrequency:DataSenderFrequency
dbhost:DBHost
dbname:DBName
dbpassword:DBPassword
dbsocket:DBSocket
dbuser:DBUser
debuglevel:DebugLevel
enableremotecommands:EnableRemoteCommands
heartbeatfrequency:HeartbeatFrequency
hostmetadata:HostMetaData
hostmetadataitem:HostMetaDataItem
hostname:Hostname
hostnameitem:HostnameItem
listenport:ListenPort
logfile:LogFile
logremotecommands:LogRemoteCommands
logtype:LogType
maxlinespersecond:MaxLinesPerSecond
proxylocalbuffer:ProxyLocalBuffer
proxymode:ProxyMode
proxyofflinebuffer:ProxyOfflineBuffer
refreshactivechecks:RefreshActiveChecks
serveractive:ServerActive
serverport:ServerPort
server:Server
startagents:StartAgents
tlsaccept:TLSAccept
tlsconnect:TLSConnect
tlspskfile:TLSPSKFile
tlspskidentity:TLSPSKIdentity
"

uci2config() {
	local enabled ucic zbxc module var
	config_load "${NAME}"
	config_get_bool enabled config enable
	[ -z "$enabled" ] && exit
	logger -s -t ${NAME} -p daemon.info "Generating conf from UCI"
	for var in $uciopts; do
		ucic=$(echo $var|cut -d ':' -f 1)
		zbxc=$(echo $var|cut -d ':' -f 2)
		config_get val config ${ucic}
		[ -n "${val}" ] && echo "${zbxc}=${val}"
		[ "$ucic" = "allowroot" ] && allowroot=$val
	done >/var/run/${NAME}.conf.d/uci
}

# Read all variables from global config section and generate /var/run/$1.conf.d/uci
uci2agentconfig() {
	local enabled ucic zbxc module var UCI_CONFIG_DIR cfg cfgf
	config_load "${NAME}"
	config_get_bool enabled config enable
	[ -z "$enabled" ] && exit
	logger -s -t ${NAME} -p daemon.info "Generating conf from UCI"
	for var in $uciopts; do
		ucic=$(echo $var|cut -d ':' -f 1)
		zbxc=$(echo $var|cut -d ':' -f 2)
		config_get val config ${ucic}
		[ -n "${val}" ] && echo "${zbxc}=${val}"
		[ "$ucic" = "allowroot" ] && allowroot=$val
	done >/var/run/${NAME}.conf.d/uci

	[ -z "$allowroot" ] && {
		user_exists zabbix 53 || user_add zabbix 53
		group_exists zabbix 53 || group_add zabbix 53
		touch ${SERVICE_PID_FILE}
		chown zabbix:zabbix ${SERVICE_PID_FILE}
	}

	for module in /lib/zabbix/*; do
		m=$(basename ${module})
		if [  -f "/etc/config/zabbix_$m" ]; then
		  unset UCI_CONFIG_DIR
		  cfg="zabbix_${m}"
		  cfgf="/etc/config/${cfg}"
		else
		  UCI_CONFIG_DIR="${module}"
		  cfg="config_uci"
		  cfgf="${module}/${cfg}"
		fi
		[ "${cfgf}" -ot /var/run/${NAME}.conf.d/${m} ] && continue
		if [ -d "${module}" ]; then
			logger -s -t ${NAME} -p daemon.info "Generating userparameters for module ${m} from UCI"
			(config_load ${cfg}
			 config_foreach uci2userparm userparm "${m}" "${sudo}" "${allowroot}"
			) >/var/run/${NAME}.conf.d/${m}
		fi 
	done
}

# $1 - configvar
# $2 - module
# $3 - sudo binary
# $4 - allowroot
uci2userparm() {
	local name key ckey cmd lock zcmd sudo
	config_get name "$1" name
	config_get key "$1" key
	config_get cmd "$1" cmd
	config_get internal "$1" internal
	config_get lock "$1" lock
	config_get sudo "$1" sudo
	
	[ -n "${sudo}" ] && [ -n "$3" ] && [ -z "$4" ] && {
		sudo="$3 ";
	}
	[ -n "${sudo}" ] && [ -z "$3" ] && [ "$4" != "1" ] && logger -s -t ${CONFIG} -p daemon.error "Disabling userparm $key (sudo is not available and allowroot=0)"
	if [ -n "$lock" ] && [ -n "$cmd" ]; then
		zcmd="${LOCKER} lock "${m}" '$lock' && ${sudo}$cmd; ${LOCKER} unlock "${m}" '$lock'"
	else
		if [ -n "$lock" ] && [ -n "$internal" ]; then
			if echo ${key} | grep -q '*'; then args='$1 $2'; else args=""; fi
			if [ "$internal" = "1" ]; then
				zcmd="${LOCKER} lockrun '${m}' '$lock' $(echo ${key}|tr '.[]*' '_   ') ${args}"
			else
				zcmd="${LOCKER} lockrun '${m}' '$lock' ${internal}"
			fi

		else
			zcmd="${sudo}$cmd"
		fi
	fi
	echo "UserParameter=${key},${zcmd}"
}

discovery_init(){
  json_init
  json_add_array data
}

discovery_add_row(){
  json_add_object "obj"
  while [ -n "$1" ]; do
    json_add_string "$1" "$2"
    shift
    shift
  done
  json_close_object
}

discovery_dump(){
 json_close_array
 json_dump
}

discovery_stdin(){
  local a b c d e f g h i j;
  discovery_init
  while read a b c d e f g h i j; do
    discovery_add_row "$1" "${1:+${a}}" "$2" "${2:+${b}}" "$3" "${3:+${c}}" "$4" "${4:+${d}}" "$5" "${5:+${e}}" "$6" "${6:+${f}}" "$7" "${7:+${g}}" "$8" "${8:+${h}}" "$9" "${9:+${i}}"
  done
  discovery_dump
}

owrt_packagediscovery(){
 local pkg version description
 
 opkg list-installed | sed "s/ \- /\|/g" | ( IFS="|"; discovery_stdin "{#PACKAGE}" "{#VERSION}" )
}

fetch_uri(){
	if [ -f "$1" ]; then
		cat "$1"
	else
		wget -q -O- "$1"
	fi
}

sqlite_sql(){
	if which sqlite3 >/dev/null; then
		echo "Feeding $1 to $2"
		fetch_uri "$1" | sqlite3 "$2"
	else
		echo "Sqlite3 binary not found. Please install it: opkg update && opkg install sqlite3-cli"
	fi
}



