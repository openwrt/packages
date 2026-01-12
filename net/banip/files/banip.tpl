# banIP mail template/include - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# info preparation
#
local banip_info report_info log_info system_info mail_text logread_cmd

if [ -f "${ban_logreadfile}" ] && [ -x "${ban_logreadcmd}" ] && [ "${ban_logreadcmd##*/}" = "tail" ]; then
	logread_cmd="${ban_logreadcmd} -qn ${ban_loglimit} ${ban_logreadfile} 2>/dev/null | ${ban_grepcmd} -e \"banIP/\" 2>/dev/null"
elif [ -x "${ban_logreadcmd}" ] && [ "${ban_logreadcmd##*/}" = "logread" ]; then
	logread_cmd="${ban_logreadcmd} -l ${ban_loglimit} -e "banIP/" 2>/dev/null"
fi

banip_info="$(/etc/init.d/banip status 2>/dev/null)"
report_info="$("${ban_catcmd}" "${ban_reportdir}/ban_report.txt" 2>/dev/null)"
log_info="$(${logread_cmd})"
system_info="$(strings /etc/banner 2>/dev/null
	"${ban_ubuscmd}" call system board |
	"${ban_awkcmd}" 'BEGIN{FS="[{}\"]"}{if($2=="kernel"||$2=="hostname"||$2=="system"||$2=="model"||$2=="description")printf "  + %-12s: %s\n",$2,$4}')"

# content header
#
mail_text="$(printf "%s\n" "<html><body><pre style='font-family:monospace;padding:20;background-color:#f3eee5;white-space:pre-wrap;overflow-x:auto;' >")"

# content body
#
mail_text="$(printf "%s\n" "${mail_text}\n<strong>++\n++ System Information ++\n++</strong>\n${system_info:-"-"}")"
mail_text="$(printf "%s\n" "${mail_text}\n\n<strong>++\n++ banIP Status ++\n++</strong>\n${banip_info:-"-"}")"
[ -n "${report_info}" ] && mail_text="$(printf "%s\n" "${mail_text}\n\n<strong>++\n++ banIP Report ++\n++</strong>\n${report_info}")"
[ -n "${log_info}" ] && mail_text="$(printf "%s\n" "${mail_text}\n\n<strong>++\n++ Logfile Information ++\n++</strong>\n${log_info}")"

# content footer
#
mail_text="$(printf "%s\n" "${mail_text}</pre></body></html>")"
