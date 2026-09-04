#!/bin/sh

# This speed testing script provides a convenient means of on-device network
# performance testing for OpenWrt routers, and subsumes functionality of the
# earlier CeroWrt scripts betterspeedtest.sh and netperfrunner.sh written by
# Rich Brown.
#
# When launched, the script uses netperf to run several upload and download
# streams to an Internet server. This places heavy load on the bottleneck link
# of your network (probably your Internet connection) while measuring the total
# bandwidth of the link during the transfers. Under this network load, the
# script simultaneously measures the latency of pings to see whether the file
# transfers affect the responsiveness of your network. Additionally, the script
# tracks the per-CPU processor usage, as well as the netperf CPU usage used for
# the test. On systems that report CPU frequency scaling, the script can also
# report per-CPU frequencies.
#
# The script operates in two modes of network loading: sequential and
# concurrent. The default sequential mode emulates a web-based speed test by
# first downloading and then uploading network streams, while concurrent mode
# provides a stress test by dowloading and uploading streams simultaneously.
#
# The script also supports measuring latency when idle as a baseline prior to
# testing under network load.
#
# NOTE: The script uses servers and network bandwidth that are provided by
# generous volunteers. Feel free to use the script to test your SQM
# configuration or troubleshoot network and latency problems, but be warned
# that continuous or high-rate use of the servers may result in denied access.
# Happy testing!
#
# For more information, consult the online README.md:
# https://github.com/openwrt/packages/blob/master/net/speedtest-netperf/files/README.md

# Usage: speedtest-netperf.sh [-4 | -6] [ -H netperf-server ] [ -t duration ] [ -p host-to-ping ] [ -n simultaneous-streams ] [ -s | -c [duration] ] [ -i [duration] ] [ -Z passphrase ]

# Options: If options are present:
#
# -H | --host:       netperf server name or IP (default netperf.bufferbloat.net)
#                    Alternate servers are netperf-east (east coast US),
#                    netperf-west (California), and netperf-eu (Denmark)
# -4 | -6:           Enable ipv4 or ipv6 testing (ipv4 is the default)
# -t | --time:       Duration of each direction's test - (default - 30 seconds)
# -p | --ping:       Host to ping to measure latency (default - one.one.one.one)
# -n | --number:     Number of simultaneous streams (default - 5 streams)
#                    based on whether concurrent or sequential upload/downloads)
# -s | -c:           Sequential or concurrent download/upload (default - disabled)
# -i | --idle:       Measure idle latency before speed test (default - disabled)
# -Z | --passphrase: Passphrase to access host. (default - none)
#                    See http://netperf.bufferbloat.net for passphrase.

# Copyright (c) 2014 - Rich Brown <rich.brown@blueberryhillsoftware.com>
# Copyright (c) 2018-2024 - Tony Ambardar <itugrok@yahoo.com>
# GPLv2


# Summarize contents of the ping's output file as min, avg, median, max, etc.
#   input parameter ($1) file contains the output of the ping command

summarize_pings() {

# Process the ping times, and summarize the results
# grep to keep lines with "time=", and sed to isolate time stamps and sort them
# awk builds an array of those values, prints first & last (which are min, max)
# and computes average.
# If the number of samples is >= 10, also computes median, and 10th and 90th
# percentile readings.
	sed 's/^.*time=\([^ ]*\) ms/\1 pingtime/' < $1 | grep -v "PING" | sort -n | awk '
BEGIN {numdrops=0; numrows=0;}
{
	if ( $2 == "pingtime" ) {
		numrows += 1;
		arr[numrows]=$1; sum+=$1;
	} else {
		numdrops += 1;
	}
}
END {
	pc10="-"; pc90="-"; med="-";
	if (numrows>=10) {
		ix=int(numrows/10); pc10=arr[ix]; ix=int(numrows*9/10);pc90=arr[ix];
		if (numrows%2==1) med=arr[(numrows+1)/2]; else med=(arr[numrows/2]);
	}
	pktloss = numdrops>0 ? numdrops/(numdrops+numrows) * 100 : 0;
	printf("  Latency: [in msec, %d pings, %4.2f%% packet loss]\n",numdrops+numrows,pktloss)
	if (numrows>0) {
		fmt="%9s: %7.3f\n"
		printf(fmt fmt fmt fmt fmt fmt, "Min",arr[1],"10pct",pc10,"Median",med,
			"Avg",sum/numrows,"90pct",pc90,"Max",arr[numrows])
	}
}'
}

# Summarize the contents of the load file, speedtest process stat file, cpuinfo
# file to show mean/stddev CPU utilization, CPU freq, netperf CPU usage.
#   input parameter ($1) file contains CPU load/frequency samples

summarize_load() {
	cat $1 /proc/$$/stat | awk -v SCRIPT_PID=$$ '
# track CPU frequencies
$1 == "cpufreq" {
	sum_freq[$2]+=$3/1000
	n_freq_samp[$2]++
}
# total CPU of speedtest processes
$1 == SCRIPT_PID {
	tot=$16+$17
	if (init_proc_cpu=="") init_proc_cpu=tot
	proc_cpu=tot-init_proc_cpu
}
# track aggregate CPU stats
$1 == "cpu" {
	tot=0; for (f=2;f<=8;f++) tot+=$f
	if (init_cpu=="") init_cpu=tot
	tot_cpu=tot-init_cpu
	n_load_samp++
}
# track per-CPU stats
$1 ~ /cpu[0-9]+/ {
	tot=0; for (f=2;f<=8;f++) tot+=$f
	usg=tot-($5+$6)
	if (init_tot[$1]=="") {
		init_tot[$1]=tot
		init_usg[$1]=usg
		cpus[n_cpus++]=$1
	}
	if (last_tot[$1]>0) {
		sum_usg_2[$1] += ((usg-last_usg[$1])/(tot-last_tot[$1]))^2
	}
	last_tot[$1]=tot
	last_usg[$1]=usg
}
END {
	printf(" CPU Load: [in %% busy (avg +/- std dev)")
	for (i in sum_freq) if (sum_freq[i]>0) {printf(" @ avg frequency"); break}
	if (n_load_samp>0) n_load_samp--
	printf(", %d samples]\n", n_load_samp)
	for (i=0;i<n_cpus;i++) {
		c=cpus[i]
		if (n_load_samp>0) {
			avg_usg=(last_tot[c]-init_tot[c])
			avg_usg=avg_usg>0 ? (last_usg[c]-init_usg[c])/avg_usg : 0
			std_usg=sum_usg_2[c]/n_load_samp-avg_usg^2
			std_usg=std_usg>0 ? sqrt(std_usg) : 0
			printf("%9s: %5.1f +/- %4.1f", c, avg_usg*100, std_usg*100)
			avg_freq=n_freq_samp[c]>0 ? sum_freq[c]/n_freq_samp[c] : 0
			if (avg_freq>0) printf("  @ %4d MHz", avg_freq)
			printf("\n")
		}
	}
	printf(" Overhead: [in %% used of total CPU available]\n")
	printf("%9s: %5.1f\n", "netperf", tot_cpu>0 ? proc_cpu/tot_cpu*100 : 0)
}'
}

# Summarize the contents of the speed file to show formatted transfer rate.
#   input parameter ($1) indicates transfer direction
#   input parameter ($2) file contains speed info from netperf

summarize_speed() {
	printf "%9s: %6.2f Mbps\n" $1 $(awk '{s+=$1} END {print s}' $2)
}

# Capture process load, then per-CPU load/frequency info at 1-second intervals.

sample_load() {
	local cpus="$(find /sys/devices/system/cpu -name 'cpu[0-9]*' 2>/dev/null)"
	local f="cpufreq/scaling_cur_freq"
	cat /proc/$$/stat
	while : ; do
		sleep 1s
		grep "^cpu[0-9]*" /proc/stat
		for c in $cpus; do
			[ -r $c/$f ] && echo "cpufreq $(basename $c) $(cat $c/$f)"
		done
	done
}

# Print a line of dots as a progress indicator.

print_dots() {
	while : ; do
		printf "."
		sleep 1s
	done
}

# Start $MAXSTREAMS datastreams between netperf client and server
# netperf writes the sole output value (in Mbps) to stdout when completed

start_netperf() {
	for i in $( seq $MAXSTREAMS ); do
		netperf $TESTPROTO -H $TESTHOST -t $1 -l $SPEEDDUR -v 0 -P 0 ${PASSPHRASE:+-Z "$PASSPHRASE"} >> $2 &
#		echo "Starting PID $! params: $TESTPROTO -H $TESTHOST -t $1 -l $SPEEDDUR -v 0 -P 0 >> $2"
	done
}

# Wait until each of the background netperf processes completes

wait_netperf() {
	# gets a list of PIDs for child processes named 'netperf'
#	echo "Process is $$"
#	echo $(pgrep -P $$ netperf)
	local err=0
	for i in $(pgrep -P $$ netperf); do
#	echo "Waiting for $i"
		wait $i || err=1
	done
	return $err
}

# Stop the background netperf processes

kill_netperf() {
	# gets a list of PIDs for child processes named 'netperf'
#	echo "Process is $$"
#	echo $(pgrep -P $$ netperf)
	for i in $(pgrep -P $$ netperf); do
#	echo "Stopping $i"
		kill -9 $i
		wait $i 2>/dev/null
	done
}

# Stop the current sample_load() process

kill_load() {
#	echo "Load: $LOAD_PID"
	kill -9 $LOAD_PID
	wait $LOAD_PID 2>/dev/null
	LOAD_PID=0
}

# Stop the current print_dots() process

kill_dots() {
#	echo "Dots: $DOTS_PID"
	kill -9 $DOTS_PID
	wait $DOTS_PID 2>/dev/null
	DOTS_PID=0
}

# Stop the current ping process

kill_pings() {
#	echo "Pings: $PING_PID"
	kill -9 $PING_PID
	wait $PING_PID 2>/dev/null
	PING_PID=0
}

# Stop the current load, pings and dots, and exit
# ping command catches and handles first Ctrl-C, so you have to hit it again...

kill_background_and_exit() {
	kill_netperf
	kill_load
	kill_dots
	rm -f $DLFILE
	rm -f $ULFILE
	rm -f $LOADFILE
	rm -f $PINGFILE
	echo; echo "Stopped"
	exit 1
}

# Measure ping latency at idle as a baseline for comparison.

measure_idle() {

	# Create temp files for netperf up/download results
	PINGFILE=$(mktemp /tmp/measurepings.XXXXXX) || exit 1
	LOADFILE=$(mktemp /tmp/measureload.XXXXXX) || exit 1
#	echo $PINGFILE $LOADFILE

	# Start dots
	print_dots &
	DOTS_PID=$!
#	echo "Dots PID: $DOTS_PID"

	# Start Ping
	ping $TESTPROTO $PINGHOST > $PINGFILE &
	PING_PID=$!
#	echo "Ping PID: $PING_PID"

	# Start CPU load sampling
	sample_load > $LOADFILE &
	LOAD_PID=$!
#	echo "Load PID: $LOAD_PID"

	# Wait for idle test period
	sleep $IDLEDUR

	# When idle time elapses, stop the CPU monitor, dots and pings
	kill_load
	kill_pings
	kill_dots
	echo

	# Summarize the ping data
	summarize_pings $PINGFILE

	# Summarize the load data
	summarize_load $LOADFILE

	# Clean up
	rm -f $PINGFILE
	rm -f $LOADFILE
}

# Measure speed, ping latency and cpu usage of netperf data transfers
# Called with direction parameter: "Download", "Upload", or "Bidirectional"
# The function gets other info from globals and command-line arguments.

measure_direction() {

	# Create temp files for netperf up/download results
	ULFILE=$(mktemp /tmp/netperfUL.XXXXXX) || exit 1
	DLFILE=$(mktemp /tmp/netperfDL.XXXXXX) || exit 1
	PINGFILE=$(mktemp /tmp/measurepings.XXXXXX) || exit 1
	LOADFILE=$(mktemp /tmp/measureload.XXXXXX) || exit 1
#	echo $ULFILE $DLFILE $PINGFILE $LOADFILE

	local dir=$1
	local spd_test

	# Start dots
	print_dots &
	DOTS_PID=$!
#	echo "Dots PID: $DOTS_PID"

	# Start Ping
	ping $TESTPROTO $PINGHOST > $PINGFILE &
	PING_PID=$!
#	echo "Ping PID: $PING_PID"

	# Start CPU load sampling
	sample_load > $LOADFILE &
	LOAD_PID=$!
#	echo "Load PID: $LOAD_PID"

	# Start netperf datastreams between client and server
	if [ $dir = "Bidirectional" ]; then
		start_netperf TCP_STREAM $ULFILE
		start_netperf TCP_MAERTS $DLFILE
	else
		# Start unidirectional netperf with the proper direction
		case $dir in
			Download) spd_test="TCP_MAERTS";;
			Upload) spd_test="TCP_STREAM";;
		esac
		start_netperf $spd_test $DLFILE
	fi

	# Wait until background netperf processes complete, check errors
	if ! wait_netperf; then
		echo
		echo "WARNING: Results may be inaccurate since 'netperf' returned errors."
		if [ -z "$PASSPHRASE" ]; then
			echo ""
			echo "         The server may require a passphrase."
			echo "         See http://$TESTHOST"
			echo ""
		fi
		echo "         Run directly for more details:"
		echo "         netperf $TESTPROTO -H $TESTHOST ${PASSPHRASE:+-Z "$PASSPHRASE"}"
	fi

	# When netperf completes, stop the CPU monitor, dots and pings
	kill_load
	kill_pings
	kill_dots
	echo

	# Print TCP Download/Upload speed
	if [ $dir = "Bidirectional" ]; then
		summarize_speed Download $DLFILE
		summarize_speed Upload $ULFILE
	else
		summarize_speed $dir $DLFILE
	fi

	# Summarize the ping data
	summarize_pings $PINGFILE

	# Summarize the load data
	summarize_load $LOADFILE

	# Clean up
	rm -f $DLFILE
	rm -f $ULFILE
	rm -f $PINGFILE
	rm -f $LOADFILE
}

print_usage() {
	echo \
"Usage: speedtest-netperf.sh [ -H netperf-server ] [ -p host-to-ping ]
                            [-4 | -6] [ -i [duration] ]
                            [ -s | -c [duration] ] [ -t duration ]
                            [ -n simultaneous-streams ] [ -Z passphrase ]"
}

is_number() {
	case "$1" in
		""|*[![:digit:]]*) return 1;;
		*) return 0 ;;
	esac
}

# ------- Start of the main routine --------

# Set initial values for defaults
TESTHOST="netperf.bufferbloat.net"
PINGHOST="one.one.one.one"
MAXSTREAMS=5
TESTPROTO="-4"
TESTSPEED=0
SPEEDDUR="30"
TESTIDLE=0
IDLEDUR="30"
PASSPHRASE=""

# Clear temp files
DLFILE=
ULFILE=
PINGFILE=
LOADFILE=

# Parse options and their parameters into variables. Options for --idle,
# --sequential and --concurrent have optional parameters.
while [ $# -gt 0 ]
do
	case "$1" in
		-i|--idle)
			TESTIDLE=1 ; shift 1
			is_number "$1" && { IDLEDUR=$1 ; shift 1 ; } ;;
		-s|--sequential)
			TESTSPEED=1 ; shift 1
			is_number "$1" && { SPEEDDUR=$1 ; shift 1 ; } ;;
		-c|--concurrent)
			TESTSPEED=2 ; shift 1
			is_number "$1" && { SPEEDDUR=$1 ; shift 1 ; } ;;
		-4|-6) TESTPROTO=$1 ; shift 1 ;;
		-H|--host)
			case "$2" in
				"") echo "Missing hostname" ; exit 1 ;;
				*) TESTHOST="$2" ; shift 2 ;;
			esac ;;
		-t|--time)
			is_number "$2" || { echo "Missing duration" ; exit 1 ; }
			IDLEDUR=$2 ; SPEEDDUR=$2 ; shift 2 ;;
		-p|--ping)
			case "$2" in
				"") echo "Missing ping host" ; exit 1 ;;
				*) PINGHOST=$2 ; shift 2 ;;
			esac ;;
		-n|--number)
			is_number $2 || { echo "Missing number of streams" ; exit 1 ; }
			MAXSTREAMS=$2 ; shift 2 ;;
		-Z|--passphrase)	
			case "$2" in 
				"") echo "Missing passphrase" ; exit 1 ;;
				*) PASSPHRASE="$2" ; shift 2 ;;
			esac ;;
		--) shift ; break ;;
		*) print_usage ; exit 1 ;;
	esac
done

# Extra argument validations

if [ $TESTIDLE -eq "0" ] && [ $TESTSPEED -eq "0" ]; then
	echo "Please select an idle latency test and/or speed test:"
	print_usage ; exit 1
fi

# Check dependencies

if ! netperf -V >/dev/null 2>&1; then
	echo "Missing netperf program, please install" ; exit 1
fi

# Catch a Ctl-C and stop background netperf, CPU stats, pinging and print_dots
trap kill_background_and_exit HUP INT TERM

# Start the main tests

DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo -n "$DATE Begin test with "
[ $TESTIDLE -eq "1" ] && echo -n "$IDLEDUR-second ping"
[ $(($TESTIDLE * $TESTSPEED)) -ne "0" ] && echo -n ", "
[ $TESTSPEED -ne "0" ] && echo -n "$SPEEDDUR-second transfer"
echo " sessions."

if [ $TESTIDLE -eq "1" ]; then
	echo "Measure idle latency by pinging $PINGHOST (IPv${TESTPROTO#-})."
	measure_idle
	echo
fi

if [ $TESTSPEED -ne "0" ]; then
	echo "Measure speed to $TESTHOST (IPv${TESTPROTO#-}) while pinging $PINGHOST."
	echo -n "Download and upload sessions are "
	[ "$TESTSPEED" -eq "1" ] && echo -n "sequential," || echo -n "concurrent,"
	echo " each with $MAXSTREAMS simultaneous streams."

	if [ $TESTSPEED -eq "1" ]; then
		measure_direction "Download"
		measure_direction "Upload"
	else
		measure_direction "Bidirectional"
	fi
fi
