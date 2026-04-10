# banIP mail template/include - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

local banip_info report_info log_info system_info mail_text

# log info preparation
#
if [ -f "${ban_logreadfile}" ] && [ -x "${ban_logreadcmd}" ] && [ "${ban_logreadcmd##*/}" = "tail" ]; then
	log_info="$("${ban_logreadcmd}" -qn "${ban_loglimit}" "${ban_logreadfile}" 2>/dev/null | "${ban_grepcmd}" -e "banIP/" 2>/dev/null)"
elif [ -x "${ban_logreadcmd}" ] && [ "${ban_logreadcmd##*/}" = "logread" ]; then
	log_info="$("${ban_logreadcmd}" -l "${ban_loglimit}" -e "banIP-" 2>/dev/null)"
fi

# banIP status and report info preparation
#
banip_info="$(/etc/init.d/banip status 2>/dev/null)"
report_info="$(< "${ban_reportdir}/ban_report.txt")" 2>/dev/null
system_info="$(strings /etc/banner 2>/dev/null; "${ban_ubuscmd}" call system board | \
	"${ban_awkcmd}" 'BEGIN{FS="[{}\"]"}{if($2=="kernel"||$2=="hostname"||$2=="system"||$2=="model"||$2=="description")printf "  + %-12s: %s\n",$2,$4}')"

# mail text preparation
#
mail_text="$(
	printf "%s\n" "<html><body><pre style='font-family:monospace;padding:20;background-color:#f3eee5;white-space:pre-wrap;overflow-x:auto;' >"
	printf "\n%s\n" "<strong>++
++ System Information ++
++</strong>"
	printf "%s\n" "${system_info:-"-"}"
	printf "\n%s\n" "<strong>++
++ banIP Status ++
++</strong>"
	printf "%s\n" "${banip_info:-"-"}"
	[ -n "${report_info}" ] && {
		printf "\n%s\n" "<strong>++
++ banIP Report ++
++</strong>"
		printf "%s\n" "${report_info}"
	}
	[ -n "${log_info}" ] && {
		printf "\n%s\n" "<strong>++
++ Logfile Information ++
++</strong>"
		printf "%s\n" "${log_info}"
	}
	printf "%s\n" "</pre></body></html>"
)"
