# banIP mail template/include - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2023 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# info preparation
#
local banip_info report_info log_info system_info mail_text

banip_info="$(/etc/init.d/banip status 2>/dev/null | awk '{NR=1;max=160;if(length($0)>max+1)while($0){if(NR==1){print substr($0,1,max)}else{print substr($0,1,max)}{$0=substr($0,max+1);NR=NR+1}}else print}')"
report_info="$(cat ${ban_reportdir}/ban_report.txt 2>/dev/null)"
log_info="$("${ban_logreadcmd}" -l 100 -e "banIP/" 2>/dev/null | awk '{NR=1;max=160;if(length($0)>max+1)while($0){if(NR==1){print substr($0,1,max)}else{print substr($0,1,max)}{$0=substr($0,max+1);NR=NR+1}}else print}')"
system_info="$(
	strings /etc/banner 2>/dev/null
	ubus call system board | awk 'BEGIN{FS="[{}\"]"}{if($2=="kernel"||$2=="hostname"||$2=="system"||$2=="model"||$2=="description")printf "  + %-12s: %s\n",$2,$4}'
)"

# content header
#
mail_text="$(printf "%s\n" "<html><body><pre style='display:block;font-family:monospace;font-size:1rem;padding:20;background-color:#f3eee5;white-space:pre'>")"

# content body
#
mail_text="$(printf "%s\n" "${mail_text}\n<strong>++\n++ System Information ++\n++</strong>\n${system_info:-"-"}")"
mail_text="$(printf "%s\n" "${mail_text}\n\n<strong>++\n++ banIP Status ++\n++</strong>\n${banip_info:-"-"}")"
[ -n "${report_info}" ] && mail_text="$(printf "%s\n" "${mail_text}\n\n<strong>++\n++ banIP Report ++\n++</strong>\n${report_info}")"
[ -n "${log_info}" ] && mail_text="$(printf "%s\n" "${mail_text}\n\n<strong>++\n++ Logfile Information ++\n++</strong>\n${log_info}")"

# content footer
#
mail_text="$(printf "%s\n" "${mail_text}</pre></body></html>")"
