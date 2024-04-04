#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

p_name="geoip-shell"
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
geoinit="${p_name}-geoinit.sh"
for geoinit_path in "$script_dir/$geoinit" "/usr/bin/$geoinit"; do
	[ -f "$geoinit_path" ] && break
done
. "$geoinit_path" || exit 1

nolog=1

usage() {
cat <<EOF

Usage: $me [-x <"expression">] [-d] [-V] [-h]
Validates a cron expression, or loads cron-related config from the config file and sets up cron jobs for geoip blocking accordingly.

Options:
  -x <"expr"> : validate cron expression

  -d          : Debug
  -V          : Version
  -h          : This help

EOF
}

val_cron_exp() {
	tolower sourceline "$1"

	reg_err() {
		err=1
		errstr="$errstr$1$_nl"
	}

	print_tip() {
		printf '%s\n%s\n%s\n' "Crontab expression format: 'minute hour day-of-month month day-of-week'." \
			"Valid example: '15 4 * * 6'." \
			"Use double quotes around your cron schedule expression." >&2
	}

	validateNum() {
		num="$1"; min="$2"; max="$3"
		case "$num" in
			'*' ) return 0 ;;
			''|*[!0-9]* ) return 1
		esac
		[ "$num" -le "$prevnum" ] && return 1
		prevnum="$num"
		return $(( num<min || num>max))
	}

	validateDay() {
		eval "case \"$1\" in
			$dow_values) abbr=1; return 0
		esac"
		return 1
	}

	validateMon() {
		eval "case \"$1\" in
			$mon_values) abbr=1; return 0
		esac"
		return 1
	}

	validateName() {
		case "$1" in
			"mon") validateMon "$2" ;;
			"dow") validateDay "$2" ;;
			*) return 1
		esac
	}

	validateField() {
		invalid_char() { reg_err "Invalid value '$1' in field '$fieldName': it $2 with '$3'."; }
		check_edge_chars() {
			case "${1%"${1#?}"}" in "$2") invalid_char "$1" "starts" "$2"; esac
			case "${1#"${1%?}"}" in "$2") invalid_char "$1" "ends" "$2"; esac
		}

		field_id="$1"
		eval "fieldName=\"\$$1\""
		fieldStr="$2"
		minval="$3"
		maxval="$4"

		segnum_field=0
		astnum_field=0

		check_edge_chars "$fieldStr" ","

		newifs ","
		for slice in $fieldStr; do
			check_edge_chars "$slice" "-"
			segnum=0 prevnum=$((minval-1)) abbr=
			IFS='-'
			for segment in $slice; do
				oldifs
				if ! validateNum "$segment" "$minval" "$maxval" ; then
					if ! validateName "$field_id" "$segment"; then
						eval "val_seg=\"\$${field_id}_values\""
						[ "$val_seg" ] && val_seg=", $val_seg"
						reg_err "Invalid segment '$segment' in field: $fieldName. Valid values: $minval-$maxval$val_seg."
					fi
				fi

				segnum=$((segnum+1))
				segnum_field=$((segnum_field+1))
				[ "$segment" = "*" ] && astnum_field=$((astnum_field+1))
			done

			[ "$segnum" -gt 2 ] || { [ "$segnum" -gt 1 ] && [ "$abbr" ]; } && reg_err "Invalid value '$slice' in $fieldName '$fieldStr'."
		done
		oldifs

		case $(( astnum_field > 0 && segnum_field > 1 )) in 1)
			reg_err "Invalid $fieldName '$fieldStr'."
		esac
	}

	err=0
	errstr=
	mn=minute
	hr=hour
	dom="day of month"
	mon=month
	dow="day of week"
	dow_values="sun|mon|tue|wed|thu|fri|sat|'*'"
	mon_values="jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|'*'"

	set -- $sourceline
	for field in mn_val hr_val dom_val mon_val dow_val; do
		case "$1" in
			'') echo; echolog -err "Not enough fields in schedule expression."
				print_tip; die ;;
			*) eval "$field"='$1'; shift
		esac
	done

	[ -n "$*" ] && {
		echo; echolog -err "Too many fields in schedule expression."
		print_tip
		die
	}

	for field in "mn $mn_val 0 59" "hr $hr_val 0 23" "dom $dom_val 1 31" "mon $mon_val 1 12" "dow $dow_val 0 6"; do
		set -- $field
		validateField "$1" "$2" "$3" "$4"
	done

	[ $err != 0 ] && {
		printf '\n\n%s\n%s\n\n' "$me: errors in cron expression:" "${errstr%"$_nl"}" >&2
		print_tip
	}

	return $err
}

while getopts ":x:dVh" opt; do
	case $opt in
		x) val_cron_exp "$OPTARG"; exit $? ;;
		d) ;;
		V) echo "$curr_ver"; exit 0 ;;
		h) usage; exit 0 ;;
		*) unknownopt
	esac
done
shift $((OPTIND-1))

extra_args "$@"

is_root_ok



check_cron_job() {
	get_matching_line "$curr_cron" "*" "${p_name}-$1" "" curr_job
	case "$curr_job" in "$2 \"$run_cmd\""*) return 0; esac
	return 1
}

get_curr_cron() {
	crontab -u root -l 2>/dev/null || die "$FAIL read crontab."
}

create_cron_job() {

	job_type="$1" w_sch=

	[ -z "$iplists" ] && die "Countries list in the config file is empty! No point in creating cron jobs."

	curr_cron="$(get_curr_cron)"
	case "$job_type" in
		update)
			[ -z "$schedule" ] && die "Cron schedule in the config file is empty!"
			check_cron_job update "$schedule" && return 0
			
			val_cron_exp "$schedule"; rv=$?
			case "$rv" in
				0)  ;;
				*) die "$FAIL validate cron schedule '$schedule'."
			esac

			rm_cron_job update
			cron_cmd="$schedule \"$run_cmd\" update -a 1>/dev/null 2>/dev/null # ${p_name}-update"
			w_sch=" with schedule '$schedule'" ;;
		persistence)
			check_cron_job persistence "@reboot" && return 0

			cron_cmd="@reboot \"$run_cmd\" restore -a 1>/dev/null 2>/dev/null # ${p_name}-persistence" ;;
		*) die "Unrecognized type of cron job: '$job_type'."
	esac

	
	printf '%s\n' "${curr_cron#"$_nl"}$_nl$cron_cmd" | crontab -u root - ||
		die "$FAIL create $job_type cron job."
}

rm_cron_job() {
	job_type="$1"

	case "$job_type" in
		update|persistence) ;;
		*) die "rm_cron_job: unknown cron job type '$job_type'."
	esac

	
	curr_cron="$(get_curr_cron)"
	printf '%s\n' "$curr_cron" | grep -v "${p_name}-${job_type}" | crontab -u root - ||
		die "$FAIL remove $job_type cron job."
}

for entry in schedule no_persist iplists; do
	getconfig "$entry"
done

run_cmd="$i_script-run.sh"

schedule="${schedule:-$default_schedule}"

check_cron_compat

printf %s "Processing cron jobs..."

case "$schedule" in
	disable) rm_cron_job update ;;
	*) create_cron_job update
esac

[ ! "$_OWRTFW" ] && {
	case "$no_persist" in
		'') create_cron_job persistence ;;
		*) rm_cron_job persistence
			echolog "${_nl}Note: no-persistence option was specified during installation. Geoip blocking will likely be deactivated upon reboot." \
			"To enable persistence, install $p_name again without the '-n' option."
	esac
}

OK
:
