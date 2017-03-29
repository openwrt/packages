
[ -f /usr/share/libubox/jshn.sh ] && . /usr/share/libubox/jshn.sh || return 1

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
