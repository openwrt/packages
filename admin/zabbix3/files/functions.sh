
[ -f /usr/share/libubox/jshn.sh ] && . /usr/share/libubox/jshn.sh

uci2config() {
	local uciopts="
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



